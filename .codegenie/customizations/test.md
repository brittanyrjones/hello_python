# Testing Practices Cheat Sheet

## Testing Libraries and Frameworks

- Jest: Primary testing framework
- @testing-library/react: For testing React components
- @testing-library/user-event: For simulating user interactions

## Mocking and Stubbing

### Jest Mocks

- Use `jest.mock()` to mock entire modules
- Use `jest.spyOn()` to create spies on specific functions
- Use `mockImplementation()` to provide custom implementations for mocked functions
- Use `mockResolvedValue()` for mocking async functions that return promises

### Example:

```javascript
jest.mock('../api/userService');
const userService = require('../api/userService');

userService.getUser.mockResolvedValue({ id: 1, name: 'John Doe' });
```

## Fake Implementations

- Create fake objects or functions to simulate complex dependencies
- Use factory functions to generate test data

### Example:

```javascript
const fakeUser = {
  id: 1,
  name: 'John Doe',
  email: 'john@example.com'
};

const createFakeUserList = (count) => {
  return Array.from({ length: count }, (_, index) => ({
    id: index + 1,
    name: `User ${index + 1}`,
    email: `user${index + 1}@example.com`
  }));
};
```

## Testing React Components

- Use `render()` from @testing-library/react to render components
- Use `screen` from @testing-library/react to query rendered elements
- Use `userEvent` from @testing-library/user-event to simulate user interactions

### Example:

```javascript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import MyComponent from './MyComponent';

test('MyComponent renders correctly', () => {
  render(<MyComponent />);
  expect(screen.getByText('Hello, World!')).toBeInTheDocument();
});

test('Button click triggers action', async () => {
  const handleClick = jest.fn();
  render(<MyComponent onClick={handleClick} />);
  await userEvent.click(screen.getByRole('button'));
  expect(handleClick).toHaveBeenCalledTimes(1);
});
```

## Asynchronous Testing

- Use `async/await` for testing asynchronous code
- Use `act()` from @testing-library/react for wrapping async operations that update component state

### Example:

```javascript
test('async operation updates component', async () => {
  jest.spyOn(api, 'fetchData').mockResolvedValue({ result: 'success' });
  
  await act(async () => {
    render(<AsyncComponent />);
  });

  expect(screen.getByText('success')).toBeInTheDocument();
});
```

## Test Structure

- Use `describe()` blocks to group related tests
- Use `beforeEach()` and `afterEach()` for setup and teardown
- Use `it()` or `test()` for individual test cases

### Example:

```javascript
describe('UserComponent', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders user information', () => {
    // Test implementation
  });

  it('handles error state', () => {
    // Test implementation
  });
});
```

## Snapshot Testing

- Use `toMatchSnapshot()` for component snapshot testing
- Update snapshots with `jest --updateSnapshot`

### Example:

```javascript
it('matches snapshot', () => {
  const { container } = render(<MyComponent />);
  expect(container).toMatchSnapshot();
});
```

## Coverage Reports

- Use Jest's built-in coverage reporting
- Run tests with `jest --coverage`
- Set coverage thresholds in Jest configuration

## Best Practices

- Write descriptive test names
- Test both success and error scenarios
- Mock external dependencies and API calls
- Use data-testid attributes for reliable element selection
- Prefer functional testing over implementation details
- Keep tests isolated and independent