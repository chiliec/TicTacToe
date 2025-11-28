import React, { useState, useEffect } from 'react'
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
} from 'react-native'
import GameScreen from './src/GameScreen'
import RatingScreen from './src/RatingScreen'
import RNBridge from './RNBridge'

export default function App() {
  const [tab, setTab] = useState<'game' | 'rating'>('game')
  const [userName, setUserName] = useState('Loading...')

  useEffect(() => {
    RNBridge.getCurrentUserName().then((name: string) => {
      setUserName(name || 'Guest')
    })
  }, [])

  return (
    <SafeAreaView style={styles.main}>
      <View style={styles.tabBar}>
        <TouchableOpacity
          onPress={() => setTab('game')}
          style={[styles.tab, tab === 'game' && styles.activeTab]}
        >
          <Text style={[styles.tabText, tab === 'game' && styles.activeTabText]}>
            🎮 Game
          </Text>
        </TouchableOpacity>
        <TouchableOpacity
          onPress={() => setTab('rating')}
          style={[styles.tab, tab === 'rating' && styles.activeTab]}
        >
          <Text style={[styles.tabText, tab === 'rating' && styles.activeTabText]}>
            🏆 Rating
          </Text>
        </TouchableOpacity>
      </View>

      {tab === 'game' ? (
        <GameScreen userName={userName} onUserNameChange={setUserName} />
      ) : (
        <RatingScreen />
      )}
    </SafeAreaView>
  )
}

const styles = StyleSheet.create({
  main: { flex: 1, backgroundColor: '#f8f9fa' },
  tabBar: {
    flexDirection: 'row',
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  tab: {
    flex: 1,
    paddingVertical: 14,
    alignItems: 'center',
  },
  activeTab: {
    borderBottomWidth: 3,
    borderBottomColor: '#007AFF',
  },
  tabText: { fontSize: 16, color: '#999', fontWeight: '500' },
  activeTabText: { color: '#007AFF', fontWeight: '700' },
})
