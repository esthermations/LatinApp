# LatinApp
![](https://img.shields.io/badge/👑-Nim-FFE220)
![](https://img.shields.io/badge/🏺-Lingua%20Latīna-B57EDC)

This is a web app written in Nim for rapidly displaying the correct macronisation of Latin words. So, for example, "amas" is correctly written "amās". When you type "amas", it will show you "amās" and what form of what word that is, really quickly. It should be helpful as a sort of spell-checker for typing Latin.

## Try it!

I keep the latest version of this app running at https://esthermations.website/LatinApp.html

## Features

 - [x] Works with first-declension nouns
 - [x] Works with first-conjugation verbs

## To-do

 - [ ] Display a short definition
 - [ ] All regular noun declensions
 - [ ] All regular verb conjugations
 - [ ] All irregular words

## Building

This program uses data processed from a download of the entire Wiktionary, which is about 6.5 GB.

If you'd like to build it yourself:

 * Head to https://dumps.wikimedia.org/enwiktionary/ and download a `pages-articles` dump
 * Extract it so you've got an enormous XML file
 * Modify `ExtractDataFromWiktionary.nim` to point to your XML file (currently it's coded for my setup)
 * Compile `ExtractDataFromWiktionary.nim` using `nim c --opt:speed src/ExtractDataFromWiktionary.nim`
 * Run it to get an `out.json` file
 * Place that `out.json` file in the project root folder
 * Run `nimble build`
 * Open `src/App.html` in your browser and hope it doesn't crash trying to load 30MB of JavaScript
