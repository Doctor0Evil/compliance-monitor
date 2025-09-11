# biometric_integration/stress_aware_bandwidth.py
import asyncio
from typing import Dict, List, Optional
from enum import Enum
import numpy as np
from datetime import datetime, time

class BiometricSensorType(Enum):
    EEG = "eeg"                 # Brain activity
    HRV = "hrv"                 # Heart rate variability
    EYE_TRACKING = "eye_tracking" # Gaze and pupil response
    GSR = "gsr"                 # Galvanic skin response
    TEMPERATURE = "temperature" # Body temperature

class StressLevel(Enum):
    CALM = 0        # 0-20: Optimal cognitive state
    FOCUSED = 1     # 21-40: Productive focus
    MILD_STRESS = 2 # 41-60: Elevated but manageable
    HIGH_STRESS = 3 # 61-80: Cognitive overload likely
    CRITICAL = 4    # 81-100: Need immediate reduction

class BiometricStressAPI:
    def __init__(self):
        self.sensors_connected: Dict[BiometricSensorType, bool] = {}
        self.stress_level = StressLevel.CALM
        self.stress_score = 0  # 0-100 scale
        self.baseline_readings: Dict[BiometricSensorType, float] = {}
        self.adaptive_bandwidth_enabled = True
        
    async def initialize_sensors(self):
        """Initialize available biometric sensors"""
        # Try to connect to each sensor type
        for sensor_type in BiometricSensorType:
            try:
                connected = await self.connect_to_sensor(sensor_type)
                self.sensors_connected[sensor_type] = connected
                
                if connected:
                    # Establish baseline readings
                    baseline = await self.capture_baseline(sensor_type)
                    self.baseline_readings[sensor_type] = baseline
                    print(f"Connected to {sensor_type.value} sensor, baseline: {baseline}")
                    
            except Exception as e:
                print(f"Failed to connect to {sensor_type.value}: {e}")
                self.sensors_connected[sensor_type] = False
        
        # Start continuous monitoring
        asyncio.create_task(self.continuous_monitoring())
    
    async def connect_to_sensor(self, sensor_type: BiometricSensorType) -> bool:
        """Connect to a specific biometric sensor"""
        # Implementation would vary by sensor type
        # This is a mock implementation
        if sensor_type == BiometricSensorType.EEG:
            return await self.connect_eeg_sensor()
        elif sensor_type == BiometricSensorType.HRV:
            return await self.connect_hrv_sensor()
        # ... other sensor types
        
        return False
    
    async def continuous_monitoring(self):
        """Continuously monitor stress levels and adjust bandwidth"""
        while True:
            try:
                # Read from all available sensors
                readings = await self.read_all_sensors()
                
                # Calculate current stress level
                new_stress_score = self.calculate_stress_score(readings)
                new_stress_level = self.score_to_stress_level(new_stress_score)
                
                # Update state if changed significantly
                if abs(new_stress_score - self.stress_score) > 5:
                    self.stress_score = new_stress_score
                    self.stress_level = new_stress_level
                    
                    print(f"Stress level updated: {new_stress_level.name} ({new_stress_score})")
                    
                    # Adjust bandwidth based on stress level
                    if self.adaptive_bandwidth_enabled:
                        await self.adjust_bandwidth_for_stress()
                
            except Exception as e:
                print(f"Monitoring error: {e}")
            
            await asyncio.sleep(2)  # Update every 2 seconds
    
    async def adjust_bandwidth_for_stress(self):
        """Adjust bandwidth allocation based on stress levels"""
        target_bandwidth = self.calculate_optimal_bandwidth()
        
        # Apply the bandwidth adjustment
        await self.apply_bandwidth_adjustment(target_bandwidth)
        
        # Also adjust quality settings if in a game context
        if self.in_game_context():
            await self.adjust_game_quality()
    
    def calculate_optimal_bandwidth(self) -> int:
        """Calculate optimal bandwidth based on stress level"""
        base_bandwidth = 100  # Default 100 Mbps
        
        if self.stress_level == StressLevel.CALM:
            # Optimal state - allow full bandwidth
            return base_bandwidth
        
        elif self.stress_level == StressLevel.FOCUSED:
            # Productive focus - slightly reduced to maintain focus
            return int(base_bandwidth * 0.9)
        
        elif self.stress_level == StressLevel.MILD_STRESS:
            # Elevated stress - reduce to prevent overload
            return int(base_bandwidth * 0.7)
        
        elif self.stress_level == StressLevel.HIGH_STRESS:
            # High stress - significant reduction needed
            return int(base_bandwidth * 0.5)
        
        else:  # StressLevel.CRITICAL
            # Critical stress - minimal bandwidth to reduce cognitive load
            return int(base_bandwidth * 0.3)
    
    async def adjust_game_quality(self):
        """Adjust game quality settings based on stress"""
        # This would interface with the game engine plugin
        stress_params = self.get_quality_adjustment_parameters()
        
        # Send adjustment to game
        await self.send_to_game_engine({
            'type': 'quality_adjustment',
            'parameters': stress_params
        })
    
    def get_quality_adjustment_parameters(self) -> Dict:
        """Get quality adjustment parameters based on stress"""
        if self.stress_level == StressLevel.CALM:
            return {'texture_quality': 'high', 'effects': 'full'}
        
        elif self.stress_level == StressLevel.FOCUSED:
            return {'texture_quality': 'high', 'effects': 'reduced'}
        
        elif self.stress_level == StressLevel.MILD_STRESS:
            return {'texture_quality': 'medium', 'effects': 'minimal'}
        
        elif self.stress_level == StressLevel.HIGH_STRESS:
            return {'texture_quality': 'low', 'effects': 'none', 'simplify_ui': True}
        
        else:  # StressLevel.CRITICAL
            return {
                'texture_quality': 'very_low', 
                'effects': 'none', 
                'simplify_ui': True,
                'reduce_animations': True,
                'color_filter': 'calming'
            }
    
    # Sensor-specific methods (mock implementations)
    async def connect_eeg_sensor(self) -> bool:
        """Connect to EEG sensor"""
        await asyncio.sleep(0.1)  # Simulate connection time
        return True  # Mock success
    
    async def connect_hrv_sensor(self) -> bool:
        """Connect to HRV sensor"""
        await asyncio.sleep(0.1)
        return True
    
    async def capture_baseline(self, sensor_type: BiometricSensorType) -> float:
        """Capture baseline reading from sensor"""
        await asyncio.sleep(0.5)  # Simulate reading time
        
        # Return mock baseline values
        baselines = {
            BiometricSensorType.EEG: 45.2,
            BiometricSensorType.HRV: 68.7,
            BiometricSensorType.EYE_TRACKING: 32.1,
            BiometricSensorType.GSR: 2.8,
            BiometricSensorType.TEMPERATURE: 36.6
        }
        
        return baselines.get(sensor_type, 0.0)
    
    async def read_all_sensors(self) -> Dict[BiometricSensorType, float]:
        """Read current values from all connected sensors"""
        readings = {}
        
        for sensor_type, connected in self.sensors_connected.items():
            if connected:
                # Simulate sensor reading with some noise
                baseline = self.baseline_readings.get(sensor_type, 0)
                noise = np.random.normal(0, baseline * 0.1)  # 10% noise
                readings[sensor_type] = baseline + noise
        
        return readings
    
    def calculate_stress_score(self, readings: Dict[BiometricSensorType, float]) -> float:
        """Calculate composite stress score from sensor readings"""
        if not readings:
            return 0.0
        
        # Simple weighted average for demonstration
        # Real implementation would use more sophisticated algorithm
        weights = {
            BiometricSensorType.EEG: 0.3,
            BiometricSensorType.HRV: 0.25,
            BiometricSensorType.EYE_TRACKING: 0.2,
            BiometricSensorType.GSR: 0.15,
            BiometricSensorType.TEMPERATURE: 0.1
        }
        
        total_score = 0.0
        total_weight = 0.0
        
        for sensor_type, value in readings.items():
            baseline = self.baseline_readings.get(sensor_type, value)
            deviation = abs(value - baseline) / baseline  # Percentage deviation
            
            # Convert deviation to stress contribution
            stress_contribution = min(deviation * 100, 100)  # Cap at 100
            weight = weights.get(sensor_type, 0)
            
            total_score += stress_contribution * weight
            total_weight += weight
        
        return total_score / total_weight if total_weight > 0 else 0.0
    
    def score_to_stress_level(self, score: float) -> StressLevel:
        """Convert stress score to stress level"""
        if score <= 20:
            return StressLevel.CALM
        elif score <= 40:
            return StressLevel.FOCUSED
        elif score <= 60:
            return StressLevel.MILD_STRESS
        elif score <= 80:
            return StressLevel.HIGH_STRESS
        else:
            return StressLevel.CRITICAL
