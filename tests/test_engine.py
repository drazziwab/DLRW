import unittest
from automator.automation_engine import run_engine

class TestAutomationEngine(unittest.TestCase):
    def test_run_engine_basic(self):
        result = run_engine(simulate=True)
        self.assertTrue(result)

if __name__ == "__main__":
    unittest.main()
