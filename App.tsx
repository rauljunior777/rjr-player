import React, { useRef, useState } from 'react';
import { StyleSheet, View, Text, TouchableOpacity } from 'react-native';
import { Video, AVPlaybackStatus, ResizeMode } from 'expo-av';

export default function App() {
  const video = useRef<Video>(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [rate, setRate] = useState<number>(1.0);

  const togglePlayback = async (): Promise<void> => {
    if (!video.current) return;
    if (isPlaying) {
      await video.current.pauseAsync();
    } else {
      await video.current.playAsync();
    }
    setIsPlaying(!isPlaying);
  };

  const changeSpeed = async (newRate: number): Promise<void> => {
    if (!video.current) return;
    setRate(newRate);
    await video.current.setRateAsync(newRate, true);
  };

  return (
    <View style={styles.container}>
      <Video
        ref={video}
        source={{ uri: 'https://www.w3schools.com/html/mov_bbb.mp4' }}
        style={styles.video}
        resizeMode={ResizeMode.CONTAIN}
        shouldPlay={false}
        useNativeControls={false}
        rate={rate}
      />

      <View style={styles.controls}>
        <TouchableOpacity onPress={togglePlayback}>
          <Text style={styles.button}>{isPlaying ? '⏸️ Pausar' : '▶️ Reproducir'}</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={() => changeSpeed(0.5)}>
          <Text style={styles.button}>🐢 Lento</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={() => changeSpeed(1.5)}>
          <Text style={styles.button}>🚀 Rápido</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#000', justifyContent: 'center' },
  video: { width: '100%', height: 300 },
  controls: { flexDirection: 'row', justifyContent: 'space-around', marginTop: 20 },
  button: { color: '#fff', fontSize: 18 },
});
