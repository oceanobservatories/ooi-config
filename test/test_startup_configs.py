import os
import yaml
import unittest

TEST_DIR = os.path.dirname(__file__)
CONFIG_DIR = os.path.abspath(os.path.join(TEST_DIR, '..', 'instrument_driver_startup'))


class StartupTest(unittest.TestCase):
    def test_all(self):
        for directory, subdirs, files in os.walk(CONFIG_DIR):
            for filename in files:
                if filename.endswith(('.yml', '.yaml')):
                    path = os.path.join(directory, filename)
                    handle = open(path, 'r')
                    d = yaml.load(handle)
                    self.assertIsInstance(d, dict)
