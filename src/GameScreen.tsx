import React, { useEffect, useState } from 'react'
import { View, Text, TouchableOpacity, Alert, StyleSheet } from 'react-native'
import RNBridge from '../RNBridge.ts'

export default function GameScreen() {
  const [board, setBoard] = useState<number[]>(Array(9).fill(0))
  const [wins, setWins] = useState(0)
  const [fails, setFails] = useState(0)
  const [startTs, setStartTs] = useState<number>(Date.now())

  useEffect(() => {
    RNBridge.addListener('requestName', (payload: any) => {
      // payload: { wins, duration }
      const duration =
        payload.duration ?? Math.floor((Date.now() - startTs) / 1000)
      Alert.prompt('You lost', 'Please enter your name to submit score', [
        { text: 'Cancel' },
        {
          text: 'Submit',
          onPress: (name: any) =>
            RNBridge.submitName(name || 'anonymous', duration),
        },
      ])
    })

    RNBridge.addListener('submitResult', (r: any) => {
      if (r.status === 'ok') Alert.alert('Sent', 'Score sent')
      else Alert.alert('Network', 'Failed to send score saved locally')
    })

    RNBridge.getStats().then((s: any) => {
      setWins(s.wins)
      setFails(s.fails)
    })
    RNBridge.startNewGame()
    RNBridge.getBoard().then((b: any) => setBoard(b))
  }, [startTs])

  async function onCellPress(i: number) {
    const res = await RNBridge.playerMove(i)
    if (res.ok) {
      const newBoard = await RNBridge.getBoard()
      setBoard(newBoard)
      if (res.aiIndex !== undefined && res.aiIndex !== null) {
        // small animation handled by layout
      }
      if (res.winner) {
        if (res.winner === 1) {
          setWins(prev => prev + 1)
        } else if (res.winner === 2) {
          setFails(prev => prev + 1)
        }
        // continue next game
        RNBridge.startNewGame()
        const b = await RNBridge.getBoard()
        setBoard(b)
        setStartTs(Date.now())
      }
    }
  }

  return (
    <View style={styles.mainView}>
      <View style={styles.childView}>
        <Text>Wins: {wins}</Text>
        <Text>Fails: {fails}</Text>
      </View>
      <View style={styles.grid}>
        {board.map((c, i) => (
          <TouchableOpacity
            key={i}
            style={styles.cell}
            onPress={() => onCellPress(i)}
          >
            <Text style={styles.cellText}>
              {c === 1 ? 'X' : c === 2 ? 'O' : ''}
            </Text>
          </TouchableOpacity>
        ))}
      </View>
    </View>
  )
}

const styles = StyleSheet.create({
  mainView: { flex: 1, padding: 20 },
  childView: { flexDirection: 'row', justifyContent: 'space-between' },
  grid: {
    width: '100%',
    aspectRatio: 1,
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  cell: {
    width: '33.3333%',
    height: '33.3333%',
    borderWidth: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  cellText: { fontSize: 38 },
})
