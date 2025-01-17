# PureFITProfile

A wrapper for [PureFIT](https://github.com/thelowlypeon/purefit).

## Usage

Simply provide data or a URL to instantiate a FITFile:

```swift
let fit = try FITFile(data: data)
```

Access messages and message data:

```swift
if let fit.messages[.record] as? [RecordMessage] {
  for record in records {
    if let timestamp = record.timestamp,
       let power = record.power {
      print("\(timestamp.formatted()): \(power.converted(to: .watts).formatted())")
    }
  }
}
```

All fields are included, regardless of whether they're recognized.
This helps make the library future-proof, as fields are added.
It also helps see what is in the file even if this library doesn't know it for whatever reason.

```swift
for messageNumber, messageGroup in fit.messages {
  if case .unknown(let number) = messageNumber {
    print("found unrecognized message: \(number)")
    for message in messageGroup {
      print(message.fields.keys.joined(separator: ", "))
  }
}
```
