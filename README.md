![CI](https://github.com/j-lgs/upload-watcher/workflows/CI/badge.svg)

## About
When run, **upload-watcher** automatically extracts and processes archives that contain albums ripped as a single track.
It's currently designed to be integrated with [Betanin](https://github.com/sentriz/betanin) and is intended for those who want to easily add CDs they have ripped to a [Beets](https://github.com/beetbox/beets) library. This image was intended to be ran as a kubernetes cronjob.

## Configuration
This table lists environment variables used by the container.
| Variable         | Description                                                            |
| ---------------- | ---------------------------------------------------------------------- |
| `BETANIN_INBOX`  | The location that this container and Betanin both expect to find media |
| `BETANIN_APIKEY` | Your Betanin API key                                                   |
| `BETANIN_HOST`   | The Betanin API's location                                             |
