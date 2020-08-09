# HowAwayAreYou

HowAwayAreYou, or shorten as Haay, is an iPhone app to help you keeping social distance with people around you.

## Important Notice

1. This app is **NOT** for serious health-care nor medical use. Please contact your local health department for medical help if needed.
2. For the same reason above, this app is **NOT** able to be downloaded from App Store. Please use it **at your own risk**.
3. The distance between your iPhone and the object person is calculated by your iPhone's dual or triple rear camera module. Since it's using disparity data to calculate distance, and the disparity info itself is **not very precise**, it's almost impossible to get the precise distance.
4. Since it needs disparity info, at least **dual rear camera** on your iPhone is required.

## Preview

![Preview Image](README_Resource/preview.gif)

## How to build

1. Run `bootstrap.sh` script to build the environment.

```sh
$ ./bootstrap.sh
```

2. Open `HowAwayAreYou.xcworkspace` with Xcode.

3. Run.

Please note that you'll need to join Apple Developer Program, as well as modifying code signing related info according to your ADP account, if you need to run / install the app on your iPhone device instead of a simulator.
