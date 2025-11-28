import React, { useEffect, useState } from 'react'
import {
  View,
  Text,
  FlatList,
  RefreshControl,
  StyleSheet,
  SafeAreaView,
} from 'react-native'
import RNBridge from '../RNBridge'
import { formatDuration } from './helpers/time'

export default function RatingScreen() {
  const [data, setData] = useState<any[]>([])
  const [refreshing, setRefreshing] = useState(false)

  const load = async () => {
    setRefreshing(true)
    try {
      const d = await RNBridge.fetchRating()
      setData(d || [])
    } catch (e: any) {
      console.warn('Failed to load rating', e)
      setData([])
    } finally {
      setRefreshing(false)
    }
  }

  useEffect(() => {
    load()
  }, [])

  return (
    <SafeAreaView style={styles.container}>
      <FlatList
        data={data}
        keyExtractor={(item, idx) => item.name + idx}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={load} />}
        renderItem={({ item, index }) => (
          <View style={styles.row}>
            <View style={styles.medal}>
              <Text style={styles.rank}>
                {index === 0 ? '🥇' : index === 1 ? '🥈' : index === 2 ? '🥉' : `#${index + 1}`}
              </Text>
            </View>
            <View style={styles.userInfo}>
              <Text style={styles.name}>{item.name}</Text>
              <View style={styles.stats}>
                <Text style={styles.stat}>
                  🔥 {item.maxStreak} streak
                </Text>
                <Text style={styles.stat}>
                  ⏱️ {formatDuration(item.totalDuration)}
                </Text>
              </View>
              <View style={styles.stats}>
                <Text style={styles.stat}>
                  {item.wins}W - {item.losses}L
                </Text>
                <Text style={[styles.stat, styles.ratio]}>
                  {(item.ratio * 100).toFixed(0)}%
                </Text>
              </View>
            </View>
          </View>
        )}
        ListEmptyComponent={
          <View style={styles.empty}>
            <Text style={styles.emptyText}>No games yet</Text>
          </View>
        }
      />
    </SafeAreaView>
  )
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f8f9fa' },
  row: {
    flexDirection: 'row',
    padding: 16,
    marginHorizontal: 12,
    marginVertical: 8,
    backgroundColor: '#fff',
    borderRadius: 12,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },
  medal: { marginRight: 16 },
  rank: { fontSize: 28 },
  userInfo: { flex: 1 },
  name: { fontSize: 16, fontWeight: '700', marginBottom: 8 },
  stats: { flexDirection: 'row', gap: 12 },
  stat: { fontSize: 13, color: '#666' },
  ratio: { color: '#007AFF', fontWeight: '600' },
  empty: { alignItems: 'center', justifyContent: 'center', padding: 40 },
  emptyText: { fontSize: 16, color: '#999' },
})
