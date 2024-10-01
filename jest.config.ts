import type { Config } from 'jest';

const config: Config = {
  watch: false,
  verbose: true,
  preset: 'ts-jest/presets/js-with-ts',
  testEnvironment: 'node',
  globalSetup: '<rootDir>/pic/global-setup.ts',
  globalTeardown: '<rootDir>/pic/global-teardown.ts',
  testTimeout: 30_000,
  transform: {
    '^.+\\.(ts|tsx|js|jsx)$': 'babel-jest',
  },
  maxWorkers: 1,
  testPathIgnorePatterns: ["<rootDir>/.mops/","<rootDir>/node_modules/", "<rootDir>/web/", "<rootDir>/scratch_tests/"],
  modulePathIgnorePatterns: ["<rootDir>/.mops/"],
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'],

};

export default config;