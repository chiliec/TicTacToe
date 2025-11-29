import React, { useEffect, useState, useRef, useMemo, useCallback } from 'react'
import { View, Text, TouchableOpacity, StyleSheet, SafeAreaView, Animated, Modal, TextInput } from 'react-native'
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

  // Format time only when elapsed changes
  const formattedTime = useMemo(() => formatTime(elapsed), [elapsed])

  const [, setIsResetting] = useState(false)

  useEffect(() => {
    if (!startTs) return
    const timer = setInterval(() => {
      setElapsed(Math.floor((Date.now() - startTs) / 1000))
    }, 100)
    return () => clearInterval(timer)
  }, [startTs])

  const initializeGame = useCallback(async () => {
    RNBridge.startNewGame()
    const b = await RNBridge.getBoard()
    setBoard(b)
  }, [])

  const resetGame = useCallback(async () => {
    setIsResetting(true)
    fadeAnim.setValue(0)
    setGameResult(null)
    setStartTs(null)
    setElapsed(0)

    RNBridge.startNewGame()
    const newBoard = await RNBridge.getBoard()
    setBoard(newBoard)
    setIsResetting(false)
  }, [fadeAnim])


  useEffect(() => {
    initializeGame()
  }, [initializeGame])

  const onCellPress = useCallback(async (i: number) => {
    if (!startTs) setStartTs(Date.now())
    const res = await RNBridge.playerMove(i)
    if (res.ok) {
      const newBoard = await RNBridge.getBoard()
      setBoard(newBoard)

      if (res.winner !== undefined) {
        const duration = Math.floor((Date.now() - (startTs || Date.now())) / 1000)
        await RNBridge.submitGame(duration, res.winner)

        fadeAnim.setValue(0)

        const resultMap: Record<number, string> = { 1: 'win', 2: 'lose', 0: 'draw' }
        setGameResult(resultMap[res.winner] || 'draw')

        Animated.timing(fadeAnim, {
          toValue: 1,
          duration: 500,
          useNativeDriver: false,
        }).start()

        setTimeout(() => resetGame(), 3000)
      }
    }
  }, [startTs, fadeAnim, resetGame])

  const onSaveName = useCallback(() => {
    const newName = tempName || 'Guest'
    RNBridge.setUserName(newName)
    onUserNameChange(newName)
    setNameModalVisible(false)
  }, [tempName, onUserNameChange])

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => setNameModalVisible(true)}>
          <Text style={styles.nameButton}>{userName}</Text>
        </TouchableOpacity>
        <Text style={styles.timer}>{formattedTime}</Text>
      </View>

      <View style={styles.grid}>
        {board.map((c, i) => (
          <Cell key={i} value={c} onPress={() => onCellPress(i)} />
        ))}
      </View>

      {gameResult && (
        <GameResultOverlay result={gameResult} fadeAnim={fadeAnim} />
      )}

      <NameModal
        visible={nameModalVisible}
        userName={tempName}
        onNameChange={setTempName}
        onSave={onSaveName}
        onCancel={() => setNameModalVisible(false)}
      />
    </SafeAreaView>
  )
}

// Extract Cell component
const Cell = React.memo(({ value, onPress }: any) => (
  <TouchableOpacity
    style={styles.cell}
    onPress={onPress}
    activeOpacity={0.7}
  >
    <Text style={styles.cellText}>
      {value === 1 ? '❌' : value === 2 ? '⭕' : ''}
    </Text>
  </TouchableOpacity>
))
Cell.displayName = 'Cell'

const GameResultOverlay = React.memo(({ result, fadeAnim }: any) => {
  const resultMessages = {
    win: "You Win! 🎉",
    lose: "You Lost! 😢",
    draw: "It's a Draw! 🤝"
  }

  return (
    <Animated.View
      style={[
        styles.overlay,
        {
          opacity: fadeAnim,
          backgroundColor: fadeAnim.interpolate({
            inputRange: [0, 1],
            outputRange: ['rgba(0,0,0,0)', 'rgba(0,0,0,0.5)'],
          })
        }
      ]}
    >
      <Text style={styles.overlayText}>
        {resultMessages[result as keyof typeof resultMessages] || resultMessages.draw}
      </Text>
    </Animated.View>
  )
})
GameResultOverlay.displayName = 'GameResultOverlay'

const NameModal = React.memo(({ visible, userName, onNameChange, onSave, onCancel }: any) => (
  <Modal visible={visible} transparent animationType="slide">
    <View style={styles.modalOverlay}>
      <View style={styles.modalContent}>
        <Text style={styles.modalTitle}>Edit Your Name</Text>
        <TextInput
          style={styles.nameInput}
          placeholder="Enter your name"
          value={userName}
          onChangeText={onNameChange}
          maxLength={30}
        />
        <View style={styles.modalButtons}>
          <TouchableOpacity
            style={[styles.modalButton, styles.cancelButton]}
            onPress={onCancel}
          >
            <Text style={styles.cancelButtonText}>Cancel</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.modalButton, styles.saveButton]}
            onPress={onSave}
          >
            <Text style={styles.saveButtonText}>Save</Text>
          </TouchableOpacity>
        </View>
      </View>
    </View>
  </Modal>
))
NameModal.displayName = 'NameModal'

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
