# Happy Birthday, Mr President.

The President has his birthday coming up and his supporters have specifically requested that people upload video messages for him (see [details](https://forms.donaldjtrump.com/landing/wish-president-trump-a-happy-birthday?utm_medium=social&utm_source=djt_tw&utm_campaign=20200604_12_birthday-card_teamtrump)).

This repo contains a Bash script that demonstrates how to upload a video file to AWS S3 from the command line, instead of from a browser.

## Pre-requisites

Requires `curl` and [`jq`](https://stedolan.github.io/jq/).

## Running

Download the script, set it to be executable:

```
chmod +x happy-birthday.sh
```

To see options, just run the script without options:
```
$ happy-birthday.sh
```

To upload a particular file and accept defaults:
```
$ happy-birthday.sh -f /path/to/my/video/file
```

## Description

The script first connects to the main website to get a CSRF token and cookie (which is written to a file called `cookie.txt`).  These are then used to get AWS connection details that describe how to upload the file to S3. The final call to curl then uploads to S3.


