# -*- coding: utf-8 -*-
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

import json

def insert_course(driver, config):
    driver.implicitly_wait(10)

    driver.get("https://studio.edge.edx.org/signin")
    driver.find_element_by_id("email").clear()
    driver.find_element_by_id("email").send_keys(config["edx_email"])
    driver.find_element_by_id("password").clear()
    driver.find_element_by_id("password").send_keys(config["edx_password"])
    WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.ID, "submit")))
    driver.find_element_by_id("submit").click()
    driver.find_element_by_id("submit").click()

    driver.find_element_by_css_selector("h3.course-title").click()

    driver.find_element_by_css_selector("div.add-section.add-item > a.button.button-new").click()
    driver.find_element_by_xpath("(//input[@value='Section'])[last()]").send_keys("AutoMDS3" + Keys.ENTER)
    driver.find_element_by_xpath('(//a[@data-default-name="Subsection"])[last()]').click()

    WebDriverWait(driver, 10).until(
        EC.visibility_of_element_located((By.XPATH, "(//input[@value='Subsection'])[last()]")))
    driver.find_element_by_xpath("(//input[@value='Subsection'])[last()]").send_keys("UBC EdX Dashboard" + Keys.ENTER)

    WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.XPATH, '(//a[@data-category="vertical"])[last()]')))
    driver.find_element_by_xpath('(//a[@data-category="vertical"])[last()]').click()

    WebDriverWait(driver, 10).until(
        EC.visibility_of_element_located((By.XPATH, '//input[@data-metadata-name="display_name"]')))
    driver.find_element_by_xpath('//input[@data-metadata-name="display_name"]').send_keys(
        "Problem Dashboard" + Keys.ENTER)

    WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.XPATH, '//button[@data-type="html"]')))
    driver.find_element_by_xpath('//button[@data-type="html"]').click()

    WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.XPATH, '//*[@id="tab1"]/ul/li[3]/button')))
    driver.find_element_by_xpath('//*[@id="tab1"]/ul/li[3]/button').click()

    driver.find_element_by_xpath('//button[@class="btn-default edit-button action-button"]').click()
    driver.find_element_by_css_selector("#mce_16 > button[type=\"button\"]").click()

    WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.CSS_SELECTOR, '.CodeMirror > div:nth-child(1) > textarea:nth-child(1)')))

    driver.execute_script('document.getElementsByClassName("CodeMirror")[0].CodeMirror.setValue("Hello World")')

    # driver.find_element_by_css_selector('.CodeMirror > div:nth-child(1) > textarea:nth-child(1)').clear()
    # driver.find_element_by_css_selector('.CodeMirror > div:nth-child(1) > textarea:nth-child(1)').send_keys("Hello World")

    driver.find_element_by_css_selector("#mce_30 > button[type=\"button\"]").click()
    driver.find_element_by_link_text("Save").click()
    driver.find_element_by_link_text("Hide from learners").click()
    driver.find_element_by_link_text("Publish").click()

if __name__ == "__main__":
    with open("../../.config.json") as config:
        config_json = json.load(config)

    options = webdriver.ChromeOptions()
    options
    driver = webdriver.Chrome()

    try:
        insert_course(driver, config_json)
    finally:
        driver.quit()
