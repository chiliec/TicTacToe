/**
 * RNBridge.ts pulls a custom native module (TicTacToeModule) off NativeModules
 * and passes it straight into `new NativeEventEmitter(...)`, which throws under
 * jest because there's no native side to register the module. Stub it here so
 * imports of RNBridge (and anything that imports it) don't blow up in tests.
 */
import { NativeModules } from 'react-native';

NativeModules.TicTacToeModule = {
  startNewGame: jest.fn(),
  getBoard: jest.fn(() => Promise.resolve(Array(9).fill(0))),
  playerMove: jest.fn(() => Promise.resolve({ ok: true })),
  getStats: jest.fn(() => Promise.resolve({})),
  getCurrentUserName: jest.fn(() => Promise.resolve('Guest')),
  setUserName: jest.fn(),
  submitGame: jest.fn(() => Promise.resolve()),
  fetchRating: jest.fn(() => Promise.resolve([])),
  addListener: jest.fn(),
  removeListeners: jest.fn(),
};
