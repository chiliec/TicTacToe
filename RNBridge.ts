import { NativeModules, NativeEventEmitter } from 'react-native';

const { TicTacToeModule } = NativeModules
const emitter = new NativeEventEmitter(TicTacToeModule)

export default {
  startNewGame: () => TicTacToeModule.startNewGame(),
  getBoard: () => TicTacToeModule.getBoard(),
  playerMove: (index: number) => TicTacToeModule.playerMove(index),
  getStats: () => TicTacToeModule.getStats(),
  submitName: (name: string, duration: number) => TicTacToeModule.submitName(name, duration),
  fetchRating: () => TicTacToeModule.fetchRating(),
  addListener: (event: string, cb: (...args: any[]) => void) => emitter.addListener(event, cb),
}