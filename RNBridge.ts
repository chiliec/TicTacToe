import { NativeModules, NativeEventEmitter } from 'react-native';
const { TicTacToeModule } = NativeModules
const emitter = new NativeEventEmitter(TicTacToeModule)

export default {
  startNewGame: () => TicTacToeModule.startNewGame(),
  getBoard: () => TicTacToeModule.getBoard(),
  playerMove: (index: number) => TicTacToeModule.playerMove(index),
  getStats: () => TicTacToeModule.getStats(),
  getCurrentUserName: () => TicTacToeModule.getCurrentUserName(),
  setUserName: (name: string) => TicTacToeModule.setUserName(name),
  submitGame: (duration: number, winner: number) => TicTacToeModule.submitGame(duration, winner),
  fetchRating: () => TicTacToeModule.fetchRating(),
  addListener: (event: string, cb: (...args: any[]) => void) => emitter.addListener(event, cb),
}
