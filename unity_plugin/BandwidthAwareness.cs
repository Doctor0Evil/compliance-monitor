// unity_plugin/BandwidthAwareness.cs
using UnityEngine;
using System.Runtime.InteropServices;
using System;

namespace BitHub.BandwidthAwareness
{
    public class BandwidthAwareness : MonoBehaviour
    {
        #region Native Plugin Imports
        [DllImport("ethoswave")]
        private static extern int GetCurrentBandwidth();
        
        [DllImport("ethoswave")]
        private static extern void SetBandwidthLimit(int bandwidthMbps);
        
        [DllImport("ethoswave")]
        private static extern bool GetEthicalMode();
        
        [DllImport("ethoswave")]
        private static extern void SetEthicalMode(bool enabled);
        #endregion
        
        public enum QualityAdaptationMode
        {
            Disabled,
            Conservative,
            Balanced,
            Aggressive
        }
        
        [Header("Bandwidth Settings")]
        public QualityAdaptationMode adaptationMode = QualityAdaptationMode.Balanced;
        public int minBandwidthMbps = 5;
        public int maxBandwidthMbps = 1000;
        
        [Header("Ethical Settings")]
        public bool respectEthicalMode = true;
        public bool allowBackgroundThrottling = true;
        
        private int currentBandwidth;
        private bool ethicalModeEnabled;
        private float lastCheckTime;
        private const float checkInterval = 2.0f;
        
        void Start()
        {
            InitializeBandwidthAwareness();
            UpdateQualitySettings();
        }
        
        void Update()
        {
            // Periodically check bandwidth and adjust settings
            if (Time.time - lastCheckTime > checkInterval)
            {
                CheckBandwidth();
                UpdateQualitySettings();
                lastCheckTime = Time.time;
            }
            
            // Respect ethical mode in real-time
            if (respectEthicalMode)
            {
                CheckEthicalMode();
            }
        }
        
        private void InitializeBandwidthAwareness()
        {
            try
            {
                currentBandwidth = GetCurrentBandwidth();
                ethicalModeEnabled = GetEthicalMode();
                lastCheckTime = Time.time;
                
                Debug.Log($"Bandwidth Awareness: Initialized with {currentBandwidth}Mbps, " +
                         $"Ethical Mode: {ethicalModeEnabled}");
            }
            catch (Exception e)
            {
                Debug.LogWarning($"Bandwidth Awareness: Failed to initialize - {e.Message}");
                currentBandwidth = maxBandwidthMbps; // Fallback to maximum
            }
        }
        
        private void CheckBandwidth()
        {
            try
            {
                int newBandwidth = GetCurrentBandwidth();
                if (newBandwidth != currentBandwidth)
                {
                    currentBandwidth = newBandwidth;
                    Debug.Log($"Bandwidth changed: {currentBandwidth}Mbps");
                }
            }
            catch (Exception e)
            {
                Debug.LogWarning($"Bandwidth check failed: {e.Message}");
            }
        }
        
        private void CheckEthicalMode()
        {
            try
            {
                bool newEthicalMode = GetEthicalMode();
                if (newEthicalMode != ethicalModeEnabled)
                {
                    ethicalModeEnabled = newEthicalMode;
                    Debug.Log($"Ethical Mode: {ethicalModeEnabled}");
                    UpdateQualitySettings();
                }
            }
            catch (Exception e)
            {
                Debug.LogWarning($"Ethical mode check failed: {e.Message}");
            }
        }
        
        private void UpdateQualitySettings()
        {
            if (adaptationMode == QualityAdaptationMode.Disabled)
                return;
                
            // Calculate adaptive quality based on bandwidth and ethical mode
            float adaptiveFactor = CalculateAdaptiveFactor();
            
            // Apply to various quality settings
            ApplyTextureQuality(adaptiveFactor);
            ApplyLODSettings(adaptiveFactor);
            ApplyStreamingSettings(adaptiveFactor);
            ApplyParticleSettings(adaptiveFactor);
            
            // Additional ethical considerations
            if (ethicalModeEnabled)
            {
                ApplyEthicalLimitations();
            }
        }
        
        private float CalculateAdaptiveFactor()
        {
            // Base factor on available bandwidth
            float bandwidthFactor = Mathf.InverseLerp(
                minBandwidthMbps, maxBandwidthMbps, currentBandwidth);
            
            // Apply adaptation mode
            switch (adaptationMode)
            {
                case QualityAdaptationMode.Conservative:
                    return Mathf.Pow(bandwidthFactor, 0.7f);
                case QualityAdaptationMode.Aggressive:
                    return Mathf.Pow(bandwidthFactor, 1.3f);
                default: // Balanced
                    return bandwidthFactor;
            }
        }
        
        private void ApplyTextureQuality(float factor)
        {
            // Adaptive texture streaming based on bandwidth
            QualitySettings.globalTextureMipmapLimit = 
                Mathf.RoundToInt(Mathf.Lerp(3, 0, factor));
                
            // Adjust texture streaming budget
            UnityEngine.Rendering.OnDemandRendering.renderScale = 
                Mathf.Lerp(0.7f, 1.5f, factor);
        }
        
        private void ApplyEthicalLimitations()
        {
            // Respect community bandwidth during peak hours
            if (IsPeakHours())
            {
                // Further reduce quality during community peak times
                QualitySettings.shadowDistance *= 0.7f;
                UnityEngine.Rendering.OnDemandRendering.renderScale *= 0.8f;
            }
            
            // Reduce background processing
            if (allowBackgroundThrottling && !Application.isFocused)
            {
                Application.backgroundLoadingPriority = 
                    ThreadPriority.Low;
                QualitySettings.asyncUploadTimeSlice = 2; // ms
            }
        }
        
        private bool IsPeakHours()
        {
            DateTime now = DateTime.Now;
            return (now.Hour >= 18 && now.Hour < 22) || // Evening peak
                   (now.Hour >= 12 && now.Hour < 14);   // Lunch peak
        }
        
        // Public API for game code
        public int GetAvailableBandwidth()
        {
            return currentBandwidth;
        }
        
        public bool IsEthicalModeEnabled()
        {
            return ethicalModeEnabled;
        }
        
        public void SetAdaptationMode(QualityAdaptationMode mode)
        {
            adaptationMode = mode;
            UpdateQualitySettings();
        }
    }
}
