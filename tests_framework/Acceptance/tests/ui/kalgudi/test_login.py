from lib.ui_lib import *

def test_login(browser, url, username, password):
	browser.get(url)
	browser.find_element_by_id('username').clear()
	browser.find_element_by_id('username').send_keys(username)
	browser.find_element_by_id('password1').send_keys(password)
	browser.find_element_by_id('login').click()
