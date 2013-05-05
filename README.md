# TwitPig

A script to demo a vulnerability in the email upload function of the twitter image service twitpic.com. The vulnerability allows to upload arbitrary images to any account.

## License

The script is licensed under the MIT License. You can find the license text in the LICENSE file.

## Disclaimer

THIS SCRIPT WAS CREATED FOR THE PURPOSE OF DEMONSTRATING THE MENTIONED SECURITY PROBLEM. YOU CAN USE IT FOR TESTING WITH ACCOUNTS THAT YOU OWN. PLEASE *DO NOT* USE IT FOR MALICIOUS MANIPULATIONS OF ANY ACCOUNTS USED BY OTHER PEOPLE. I TAKE NO RESPONSIBILITY FOR ANY HARM DONE.

## Background

At the time of the creation of this script (2012) the email upload function of twitpic.com worked the following way. A picture can be posted to an account by sending an email with the image attached to <username>.<pin>@twitpic.com where pin is a four-digit secret number chosen by the user. The problem is that the number is the same for all uploads until it is changed by the user and the mail-address of the sender cannot be restricted (which could be checked by DKIM). Instead the twitpic STMP server accepts mail from any sender and it also accepts an unlimited number of retries. These constraints make the email upload function a feasible target to brute force attacks. This is what the script does by simply trying all pins from 0000 to 9999. The twitpic.com blog mentions a fixed security problem with the email upload from the past http://blog.twitpic.com/2009/06/email-posting-vulnerability-fixed/.

## Usage

twitpig.pl username [imagefile [caption]]

