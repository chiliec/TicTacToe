import React, { useState } from 'react'
import { View, Text, TouchableOpacity, StyleSheet, SafeAreaView } from 'react-native'
// import { SafeAreaView } from 'react-native-safe-area-context';
import GameScreen from './src/GameScreen'
import RatingScreen from './src/RatingScreen'

export default function App() {
  const [tab, setTab] = useState<'game'|'rating'>('game')

  return (
    <SafeAreaView style={styles.main}>
      <View style={styles.tabs}>
        <TouchableOpacity onPress={() => setTab('game')} style={styles.tabButton}>
          <Text>🎮 Game</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={() => setTab('rating')} style={styles.tabButton}>
          <Text>🏆 Rating</Text>
        </TouchableOpacity>
      </View>
      {tab === 'game' ? <GameScreen /> : <RatingScreen />}
    </SafeAreaView>
  )
}

const styles = StyleSheet.create({
  main: { flex: 1 },
  tabs: { flexDirection: 'row', justifyContent: 'space-around', padding: 12 },
  tabButton: { padding: 8 }
})
