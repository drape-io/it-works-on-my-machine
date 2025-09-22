module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  
  // Test file patterns
  testMatch: [
    '**/__tests__/**/*.ts',
    '**/?(*.)+(spec|test).ts'
  ],
  
  // Coverage configuration
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts',
    '!src/index.ts'
  ],
  coverageDirectory: '../reports/typescript/coverage',
  coverageReporters: [
    'text',
    'lcov', 
    'html',
    'cobertura'
  ],
  
  // JUnit XML reporter for CI
  reporters: [
    'default',
    ['jest-junit', {
      outputDirectory: '../reports/typescript',
      outputName: 'junit.xml',
      uniqueOutputName: false,
      suiteName: 'TypeScript Flaky Tests',
      classNameTemplate: '{classname}',
      titleTemplate: '{title}'
    }]
  ],
  
  // Timeout configuration for flaky tests
  testTimeout: 10000,
  
  
  // Module resolution
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1'
  },
  
  // Transform configuration with ts-jest options
  transform: {
    '^.+\\.ts$': ['ts-jest', {
      useESM: false,
      tsconfig: 'tsconfig.json'
    }]
  },
  
  // Verbose output for debugging flaky tests
  verbose: true,
  
  // Let CI handle retries instead of Jest retries
  
  // Clear mocks between tests
  clearMocks: true,
  restoreMocks: true,
  resetMocks: true
};
