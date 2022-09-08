import code
import unittest


class TestCode(unittest.TestCase):
    @classmethod
    def setupClass(cls):
        print("Starting unit tests")
        return

    def test_rc(self):
        code.read_data()
        code.model_standard_scaler()
        score = code.fit_random_forest()
        if score < 0.9:
            print("Test score below threshold")
        else:
            print("Test score above threshold")
        self.assertTrue(score > 0.9)
        return

    def test_rfs(self):
        code.read_data()
        code.model_standard_scaler()
        score = code.rfs_pipeline()
        if score < 0.9:
            print("Test score below threshold")
        else:
            print("Test score above threshold")
        self.assertTrue(score > 0.9)
        return

    def test_cfs(self):
        code.read_data()
        code.model_standard_scaler()
        score = code.cfs_pipeline()
        if score < 0.9:
            print("Test score below threshold")
        else:
            print("Test score above threshold")
        self.assertTrue(score > 0.9)
        return

    @classmethod
    def teardownClass(cls):
        print("Tearing down class")
        return
