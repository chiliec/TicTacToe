import React, { useEffect, useState } from 'react'
import { View, Text, FlatList, RefreshControl, StyleSheet } from 'react-native'
import RNBridge from '../RNBridge.ts'

export default function RatingScreen() {
  const [data, setData] = useState<any[]>([])
  const [refreshing, setRefreshing] = useState(false)

  const load = async () => {
    setRefreshing(true)
    try {
      const d = await RNBridge.fetchRating()
      // expecting array of {name,wins,fails}
      const normalized = (d || []).map((row: {name: string, wins: number, fails: number}) => ({
        name: row.name || 'anon',
        wins: row.wins || 0,
        fails: row.fails || 0,
      }))
      // sort by ratio wins/(wins+fails)
      normalized.sort(
        (a: { wins: number; fails: number }, b: { wins: number; fails: number }) => {
          const ra = a.wins / Math.max(1, a.wins + a.fails)
          const rb = b.wins / Math.max(1, b.wins + b.fails)
          return rb - ra
        },
      )
      setData(normalized)
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
    <View style={styles.mainView}>
      <FlatList
        data={data}
        keyExtractor={(item, idx) => item.name + idx}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={load} />
        }
        renderItem={({ item }) => (
          <View style={styles.rowView}>
            <Text style={styles.rowTitle}>{item.name}</Text>
            <Text>
              Wins: {item.wins} Fails: {item.fails} Ratio:{' '}
              {(
                (item.wins / Math.max(1, item.wins + item.fails)) *
                100
              ).toFixed(0)}
              %
            </Text>
          </View>
        )}
      />
    </View>
  )
}

const styles = StyleSheet.create({
  mainView: { flex: 1 },
  rowView: { padding: 12, borderBottomWidth: 1 },
  rowTitle: { fontWeight: '600' },
})
