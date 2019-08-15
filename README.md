*This package is supporting v1 of the API which will no longer be in use as of July 1, ,2020. It's recommended to use the new v3 of the API, see full documentation with code snippets here - https://api.copyleaks.com/documentation/v3*

Copyleaks finds plagiarism online using copyright infringement detection technology. Find those who have used your content with Copyleaks. See here how to integrate Copyleaks easily with your services, using Java, to detect plagiarism.

## Copyleaks API Swift SDK

Copyleaks SDK is a simple framework that allows you to scan textual content for plagiarism and trace content online, using the [Copyleaks plagiarism checker cloud](https://copyleaks.com/).

Detect plagiarism using Copyleaks SDK in:
- Online content and webpages
- Local and cloud files ([see supported files](https://api.copyleaks.com/GeneralDocumentation/TechnicalSpecifications#supportedfiletypes"))
- Free text
- OCR (Optical Character Recognition) - scanning pictures with textual content ([see supported files](https://api.copyleaks.com/GeneralDocumentation/TechnicalSpecifications#supportedfiletypes))

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


If you want to disable all callbacks you can add the header `no_callback: true ` to any of the 'create' methods (`no_http_callback` or `no_email_callback` to disable only one). `no_custom_fields` works the same way.

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

### Examples

For a fast testing, clone the repo, and run `pod install` from the Example directory first with your email and api_key values.
