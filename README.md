## Copyleaks Swift SDK

[![CI Status](http://img.shields.io/travis/Eugene Vegner/PlagiarismChecker.svg?style=flat)](https://travis-ci.org/Eugene Vegner/PlagiarismChecker)
[![Version](https://img.shields.io/cocoapods/v/PlagiarismChecker.svg?style=flat)](http://cocoapods.org/pods/PlagiarismChecker)
[![License](https://img.shields.io/cocoapods/l/PlagiarismChecker.svg?style=flat)](http://cocoapods.org/pods/PlagiarismChecker)
[![Platform](https://img.shields.io/cocoapods/p/PlagiarismChecker.svg?style=flat)](http://cocoapods.org/pods/PlagiarismChecker)

Copyleaks SDK is a simple framework that allows you to scan textual content for plagiarism and trace content online, using the [Copyleaks plagiarism checker cloud](https://copyleaks.com/).

Detect plagiarism using Copyleaks SDK in:
- Online content and webpages
- Local and cloud files ([see supported files](https://api.copyleaks.com/Documentation/TechnicalSpecifications/#non-textual-formats"))
- Free text
- OCR (Optical Character Recognition) - scanning pictures with textual content ([see supported files](https://api.copyleaks.com/Documentation/TechnicalSpecifications/#ocr-formats))

## Installation

Copyleaks Plagiarism Checker is available on [CocoaPods](https://cocoapods.org/?q=copyleaks). To install, simply add the following line to your Podfile:

```ruby
pod "PlagiarismChecker"
```

## Usage

First, login with your api-key and email:
```ruby
 let cloud = CopyleaksCloud(.Businesses)
            cloud.login(email, apiKey: key, success: { (result) in
                self.activityIndicator.stopAnimating()
```

Then you can start to scan content for plagiarism. For example, scan picture with textual content for plagirism:
```ruby
cloud.createByOCR(fileURL: NSURL(string: imagePath)!, language: "English") { (result) in
            self.activityIndicator.stopAnimating()
```

Methods `create_by_url`, `create_by_file`, `create_by_text`, `status`, `result` and `list` returns `CopyleaksApi::CopyleaksProcess` objects. You will get back the status `Finished` if the process finished running.


If you want to disable all callbacks you can add the header `no_callbak: true ` to any of the 'create' methods (`no_http_callback` or `no_email_callback` to disable only one). `no_custom_fields` works the same way.

### Errors

| Class | Description |
|-------|------------|
BasicError | Superclass error 
BadCustomFieldError | Given custom fields didn't pass validation (key/value/overall size is too large)
BadFileError | Given file is too large
BadEmailError | Given call back email is invalid
BadUrlError | Given callback url is invalid
UnknownLanguageError | Given OCR language is invalid
BadResponseError | Response from API is not 200 code
ManagedError | Response contains Copyleaks managed error code (see list [here](https://api.copyleaks.com/Documentation/ErrorList))

##Examples

For a fast testing, clone the repo, and run `pod install` from the Example directory first with your email and api_key values.
