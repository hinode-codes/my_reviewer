# TODO

- [ ] fix: must show retrying on UI instead of pure failure if still being retried/requeued automatically.
- [ ] fix: retry from button must reflect right away (optimistic).
- [ ] fix: retry from button must reflect allowable attempts specified and not just one time.
- [ ] fix: notification must show progress of totality. (failure, in queue, running, dead, retrying, current id of job)
- [ ] verify: check edge ocr whether it's closing the model right away, since it shouldn't allow for quick transcriptions for consecutive queues. Only close once finished.
- [ ] fix: turn background downloader into purely background without a blocking modal so user can navigate pages. (since it is a background downloader xD), therefore, make verification of files run in the background too. no need to integrate the model on the main thread.
- [ ] fix: don't store huge lists on transcription screen. Just the currently visible transcription AND its two neighbors. This will allow for low memory usage on the main UI thread/isolate.
- [ ] fix: metadata like timer must be properly updated in the transcription page.
- [ ] ui: page image viewer to transcription viewer must fade away smoothly.
- [ ] ui: transcription viewer to main group docs list must have sound and proper transition of hero page for no sudden jumping of image.
- [ ] docs: document job's structure, and find other way to have more data integrity.
