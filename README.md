kalgudi_test_automation
=======================

test_automation

# Kalgudi App Regression Suite

A test suite to run API and UI tests on the kalgudi Application

## Features

You can run tests that are:
* File specific
* UI specific
* API specific

To run the tests all you need (apart from the test suite dependencies) are:
* Your store URL
* Your store username
* Your store password


## Installation

Run the installation script from your terminal (and wait a while):

```
$ ./install.sh
Clearing install logs                             [ OKAY ]
Installing Homebrew                               [ OKAY ]
...
Done.
```

If something goes wrong, have a look at the newly-created `install.log`; it lists the commands run, with the resulting output for each.

You should be able to run `./install.sh` as many times as you like without ill effect.

### Running all tests

		bash tests/run.sh

### Running a single test

    py.test tests/path/to/test.py --url=https://xxxxxx --username=xxxxx --password=xxxxx --browser=browser_name

    # eg. tests/ui/test_brand_crud.py
    py.test tests/ui/test_brand_crud.py --url=https://store-123.example.com --username=admin --password=foobar1 --browser=chrome

By default test will run on headless browser. To run the tests on firefox use `--browser=firefox`; for Chrome use `--browser=chrome`

### Running all tests in a folder

    py.test tests/folder --url=https://xxxxxx --username=xxxxx --password=xxxxx

    # eg. API tests:
    py.test tests/api --url=https://store-123.example.com --username=admin --password=foobar1 --browser=chrome

    # eg. UI tests:
    py.test tests/ui --url=https://store-123.example.com --username=admin --password=foobar1 --browser=chrome


## Troubleshooting

**Q)** When you run the tests on Chrome you may get the following error, "ChromeDriver executable needs to be available in the path"  
**A)** Run the following command: `echo "export PATH=$PATH:/usr/local/Cellar/chromedriver/2.4/bin" >> $HOME/.bash_profile`
