// ethoswave_driver/ethoswave.c
#include <ntddk.h>
#include <wdf.h>
#include "ethoswave.h"

DRIVER_INITIALIZE DriverEntry;
EVT_WDF_DRIVER_DEVICE_ADD EthoswaveEvtDeviceAdd;
EVT_WDF_IO_QUEUE_IO_DEVICE_CONTROL EthoswaveEvtIoDeviceControl;

typedef struct _DEVICE_CONTEXT {
    ULONG current_bandwidth;
    ULONG max_bandwidth;
    BOOLEAN ethical_mode;
    PVOID policy_buffer;
    size_t policy_size;
} DEVICE_CONTEXT, *PDEVICE_CONTEXT;

WDF_DECLARE_CONTEXT_TYPE_WITH_NAME(DEVICE_CONTEXT, GetDeviceContext)

NTSTATUS DriverEntry(PDRIVER_OBJECT DriverObject, PUNICODE_STRING RegistryPath) {
    WDF_DRIVER_CONFIG config;
    NTSTATUS status;
    
    WDF_DRIVER_CONFIG_INIT(&config, EthoswaveEvtDeviceAdd);
    config.DriverPoolTag = 'ETHO';
    
    status = WdfDriverCreate(DriverObject, RegistryPath, WDF_NO_OBJECT_ATTRIBUTES, &config, WDF_NO_HANDLE);
    
    if (!NT_SUCCESS(status)) {
        KdPrint(("Ethoswave: DriverEntry failed: 0x%x\n", status));
    }
    
    return status;
}

NTSTATUS EthoswaveEvtDeviceAdd(WDFDRIVER Driver, PWDFDEVICE_INIT DeviceInit) {
    NTSTATUS status;
    WDFDEVICE device;
    WDF_IO_QUEUE_CONFIG queueConfig;
    WDF_OBJECT_ATTRIBUTES deviceAttributes;
    
    UNREFERENCED_PARAMETER(Driver);
    
    WDF_OBJECT_ATTRIBUTES_INIT_CONTEXT_TYPE(&deviceAttributes, DEVICE_CONTEXT);
    
    status = WdfDeviceCreate(&DeviceInit, &deviceAttributes, &device);
    
    if (!NT_SUCCESS(status)) {
        KdPrint(("Ethoswave: WdfDeviceCreate failed: 0x%x\n", status));
        return status;
    }
    
    WDF_IO_QUEUE_CONFIG_INIT_DEFAULT_QUEUE(&queueConfig, WdfIoQueueDispatchParallel);
    queueConfig.EvtIoDeviceControl = EthoswaveEvtIoDeviceControl;
    
    status = WdfIoQueueCreate(device, &queueConfig, WDF_NO_OBJECT_ATTRIBUTES, WDF_NO_HANDLE);
    
    if (!NT_SUCCESS(status)) {
        KdPrint(("Ethoswave: WdfIoQueueCreate failed: 0x%x\n", status));
        return status;
    }
    
    PDEVICE_CONTEXT pContext = GetDeviceContext(device);
    pContext->current_bandwidth = 1000; // 1 Gbps default
    pContext->max_bandwidth = 1000;
    pContext->ethical_mode = TRUE;
    
    return status;
}

VOID EthoswaveEvtIoDeviceControl(
    WDFQUEUE Queue,
    WDFREQUEST Request,
    size_t OutputBufferLength,
    size_t InputBufferLength,
    ULONG IoControlCode
) {
    NTSTATUS status = STATUS_SUCCESS;
    WDFDEVICE device = WdfIoQueueGetDevice(Queue);
    PDEVICE_CONTEXT pContext = GetDeviceContext(device);
    size_t length = 0;
    PVOID buffer = NULL;
    
    switch (IoControlCode) {
        case IOCTL_ETHOSWAVE_SET_BANDWIDTH:
            status = WdfRequestRetrieveInputBuffer(Request, sizeof(ULONG), &buffer, &length);
            if (NT_SUCCESS(status) && length >= sizeof(ULONG)) {
                ULONG new_bandwidth = *(PULONG)buffer;
                if (new_bandwidth <= pContext->max_bandwidth) {
                    pContext->current_bandwidth = new_bandwidth;
                    KdPrint(("Ethoswave: Bandwidth set to %lu Mbps\n", new_bandwidth));
                } else {
                    status = STATUS_INVALID_PARAMETER;
                }
            }
            break;
            
        case IOCTL_ETHOSWAVE_GET_BANDWIDTH:
            status = WdfRequestRetrieveOutputBuffer(Request, sizeof(ULONG), &buffer, &length);
            if (NT_SUCCESS(status) && length >= sizeof(ULONG)) {
                *(PULONG)buffer = pContext->current_bandwidth;
                WdfRequestSetInformation(Request, sizeof(ULONG));
            }
            break;
            
        case IOCTL_ETHOSWAVE_SET_ETHICAL_MODE:
            status = WdfRequestRetrieveInputBuffer(Request, sizeof(BOOLEAN), &buffer, &length);
            if (NT_SUCCESS(status) && length >= sizeof(BOOLEAN)) {
                pContext->ethical_mode = *(PBOOLEAN)buffer;
                KdPrint(("Ethoswave: Ethical mode %s\n", pContext->ethical_mode ? "enabled" : "disabled"));
            }
            break;
            
        case IOCTL_ETHOSWAVE_LOAD_POLICY:
            status = WdfRequestRetrieveInputBuffer(Request, 0, &buffer, &length);
            if (NT_SUCCESS(status)) {
                if (pContext->policy_buffer) {
                    ExFreePool(pContext->policy_buffer);
                }
                pContext->policy_buffer = ExAllocatePoolWithTag(NonPagedPool, length, 'ETHO');
                if (pContext->policy_buffer) {
                    RtlCopyMemory(pContext->policy_buffer, buffer, length);
                    pContext->policy_size = length;
                    KdPrint(("Ethoswave: Policy loaded (%zu bytes)\n", length));
                } else {
                    status = STATUS_INSUFFICIENT_RESOURCES;
                }
            }
            break;
            
        default:
            status = STATUS_INVALID_DEVICE_REQUEST;
            break;
    }
    
    WdfRequestComplete(Request, status);
}
