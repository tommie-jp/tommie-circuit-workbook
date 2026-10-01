import { test } from 'node:test';
import assert from 'node:assert/strict';
import { plantumlSources } from './plantuml.mjs';

test('extracts only the plantuml fences, in order', () => {
  const text = '# t\n\n```plantuml\n@startuml\nA --> B\n@enduml\n```\n\n```text\nx\n```\n\n```plantuml\n@startuml\n@enduml\n```\n';

  assert.deepEqual(plantumlSources(text), ['@startuml\nA --> B\n@enduml\n', '@startuml\n@enduml\n']);
});

test('returns nothing when there is no plantuml fence', () => {
  assert.deepEqual(plantumlSources('```circuit\n```\n'), []);
});
