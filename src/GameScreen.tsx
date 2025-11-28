import React, { useEffect, useState, useRef } from 'react'
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  Animated,
  Modal,
  TextInput,
} from 'react-native'
import RNBridge from '../RNBridge'
import { formatTime } from './helpers/time'

export default function GameScreen({ userName, onUserNameChange }: any) {
  const [board, setBoard] = useState<number[]>(Array(9).fill(0))
  const [startTs, setStartTs] = useState<number | null>(null)
  const [elapsed, setElapsed] = useState(0)
  const [gameResult, setGameResult] = useState<string | null>(null)
  const fadeAnim = useRef(new Animated.Value(0)).current
  const [nameModalVisible, setNameModalVisible] = useState(false)
  const [tempName, setTempName] = useState(userName)

  useEffect(() => {
    if (!startTs) return
    const timer = setInterval(() => {
      setElapsed(Math.floor((Date.now() - startTs) / 1000))
    }, 100)
    return () => clearInterval(timer)
  }, [startTs])

  useEffect(() => {
    RNBridge.startNewGame()
    RNBridge.getBoard().then((b: any) => setBoard(b))
  }, [])

  async function onCellPress(i: number) {
    if (!startTs) setStartTs(Date.now())
    const res = await RNBridge.playerMove(i)
    if (res.ok) {
      const newBoard = await RNBridge.getBoard()
      setBoard(newBoard)

      if (res.winner !== undefined) {
        const duration = Math.floor((Date.now() - (startTs || Date.now())) / 1000)
        await RNBridge.submitGame(duration, res.winner)

        fadeAnim.setValue(0)

        if (res.winner === 1) {
          setGameResult('win')
        } else if (res.winner === 2) {
          setGameResult('lose')
        } else if (res.winner === 0) {
          setGameResult('draw')
        }

        Animated.timing(fadeAnim, {
          toValue: 1,
          duration: 500,
          useNativeDriver: false,
        }).start()

        setTimeout(() => {
          setGameResult(null)
          fadeAnim.setValue(0)
          RNBridge.startNewGame()
          RNBridge.getBoard().then((b: any) => setBoard(b))
          setStartTs(null)
          setElapsed(0)
        }, 3000)
      }
    }
  }

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => setNameModalVisible(true)}>
          <Text style={styles.nameButton}>{userName}</Text>
        </TouchableOpacity>
        <Text style={styles.timer}>{formatTime(elapsed)}</Text>
      </View>

      <View style={styles.grid}>
        {board.map((c, i) => (
          <TouchableOpacity
            key={i}
            style={styles.cell}
            onPress={() => onCellPress(i)}
            activeOpacity={0.7}
          >
            <Text style={styles.cellText}>
              {c === 1 ? '❌' : c === 2 ? '⭕' : ''}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      {gameResult && (
        <Animated.View
          style={[
            styles.overlay,
            { opacity: fadeAnim, backgroundColor: fadeAnim.interpolate({
              inputRange: [0, 1],
              outputRange: ['rgba(0,0,0,0)', 'rgba(0,0,0,0.5)'],
            })}
          ]}
        >
          <Text style={styles.overlayText}>
            {gameResult === 'win' && "You Win! 🎉"}
            {gameResult === 'lose' && "You Lost! 😢"}
            {gameResult === 'draw' && "It's a Draw! 🤝"}
          </Text>
        </Animated.View>
      )}

      <Modal visible={nameModalVisible} transparent animationType="slide">
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <Text style={styles.modalTitle}>Edit Your Name</Text>
            <TextInput
              style={styles.nameInput}
              placeholder="Enter your name"
              value={tempName}
              onChangeText={setTempName}
              maxLength={30}
            />
            <View style={styles.modalButtons}>
              <TouchableOpacity
                style={[styles.modalButton, styles.cancelButton]}
                onPress={() => setNameModalVisible(false)}
              >
                <Text style={styles.cancelButtonText}>Cancel</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.modalButton, styles.saveButton]}
                onPress={() => {
                  RNBridge.setUserName(tempName || 'Guest')
                  onUserNameChange(tempName || 'Guest')
                  setNameModalVisible(false)
                }}
              >
                <Text style={styles.saveButtonText}>Save</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>
    </SafeAreaView>
  )
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f8f9fa', padding: 16 },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 24,
  },
  nameButton: {
    fontSize: 18,
    fontWeight: '600',
    color: '#007AFF',
    paddingVertical: 8,
    paddingHorizontal: 12,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#007AFF',
  },
  timer: { fontSize: 20, fontWeight: '700', color: '#333' },
  grid: {
    width: '100%',
    aspectRatio: 1,
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginBottom: 20,
  },
  cell: {
    width: '31%',
    aspectRatio: 1,
    backgroundColor: '#fff',
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  cellText: { fontSize: 48 },
  overlay: {
    ...StyleSheet.absoluteFillObject,
    justifyContent: 'center',
    alignItems: 'center',
  },
  overlayText: { fontSize: 36, fontWeight: '700', color: '#fff' },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'flex-end',
  },
  modalContent: {
    backgroundColor: '#fff',
    paddingHorizontal: 20,
    paddingVertical: 30,
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
  },
  modalTitle: { fontSize: 20, fontWeight: '700', marginBottom: 16 },
  nameInput: {
    borderWidth: 1,
    borderColor: '#ccc',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
    marginBottom: 20,
  },
  modalButtons: { flexDirection: 'row', gap: 12 },
  modalButton: { flex: 1, paddingVertical: 12, borderRadius: 8 },
  cancelButton: { backgroundColor: '#f0f0f0' },
  saveButton: { backgroundColor: '#007AFF' },
  cancelButtonText: { textAlign: 'center', fontSize: 16, color: '#333' },
  saveButtonText: { textAlign: 'center', fontSize: 16, color: '#fff', fontWeight: '600' },
})
