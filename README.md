# Network Fixer

The tool will enable network access for Chinese iPhones in iOS 12 or iOS 13. 

## Background

* Due to regional regulations, Chinese iPhones may suffer from offline of checkra1n loader and cydia app.

* The idea came from @laoyur. The detail can be found at: https://github.com/pwn20wndstuff/Undecimus/issues/136

* In iOS 13, the related APIs were moved from `Preferences.framework` to `SettingsCellular.framework`.

## Supported

* iOS 12
* iOS 13

## How to Use

```bash
networkfixer com.example.bundleid
```

You can find latest deb file in `packages` or you may want build it on your own.
