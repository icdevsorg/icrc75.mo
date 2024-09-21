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
  testPathIgnorePatterns: ["/node_modules/", "/frontend/", "/scratch_tests/"],
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'],

};

export default config;