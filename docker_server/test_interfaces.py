import os
import unittest
import database_scripts.controlPanelInterface as CPI 
import database_scripts.lblogbookInterface as LBI
import database_scripts.prometheusInterface as PI

class TestControlPanelInterface(unittest.TestCase):

    def test_commad_whitelist(self):
        CP=CPI.ControlPanel()
        state = 'NotAllowedCommand'
        self.assertEqual(CP.get(state), f'Not allowed state: {state}')
        state = CPI.allowed_states[0]
        self.assertNotEqual(CP.get(state), f'Not allowed state: {state}')
        
        #This requires a real responce
        self.assertEqual(list(CP.get(state).keys())[0], state)

    # The environment tests have been removed because the environment is not set 
    # when the testing phase occurs
    #def test_environment(self):
        # The error message of assertIn was too long because it printed out
        # the os.environ. It was too annoying.
        #self.assertIn('LBLOGBOOK_SOURCE', os.environ, 'This variable should be set!')
        #self.assertTrue('CONTROL_PANEL_SOURCE' in os.environ, 'This variable should be set!')
        #



class TestLogbookInterface(unittest.TestCase):

    def test_number_constraint(self):
        LB = LBI.LbLogbook()
        self.assertEqual(LB.get('notANumber'),'Not a number!')
        #Too large number
        self.assertEqual(LB.get('1000'),'Number must be smaller than 1000!')

    #def test_environment(self):
        # The error message of assertIn was too long because it printed out
        # the os.environ. It was too annoying.
        #self.assertIn('LBLOGBOOK_SOURCE', os.environ, 'This variable should be set!')
        #self.assertTrue('CONTROL_PANEL_SOURCE' in os.environ, 'This variable should be set!')

class TestPrometheusInterface(unittest.TestCase):

    def test_commad_whitelist(self):
        P=PI.Prometheus()
        state = 'NotAllowedCommand'
        self.assertEqual(P.get(state), {})
        # This requires a real responce and currently
        # I am not able to get the server to connect while testing.
        # If this test works while deployed, we should uncomment this
        #state = PI.allowed_commands[0]
        #self.assertNotEqual(P.get(state), {})
        #print(P.get(state))

    #def test_environment(self):
        # The error message of assertIn was too long because it printed out
        # the os.environ. It was too annoying.
        #self.assertIn('LBLOGBOOK_SOURCE', os.environ, 'This variable should be set!')
        #self.assertTrue('PROMETHEUS_SOURCE' in os.environ, 'This variable should be set!')

if __name__ == '__main__':
    unittest.main()