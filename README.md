# LatinApp
![](https://img.shields.io/badge/👑-Nim-FFE220)
![](https://img.shields.io/badge/🏺-Lingua%20Latīna-B57EDC)

## Features

 * Displays macronisation of Latin words as you type them

## To-do

 * Display a short definition
 * Handle macronisation of multiple senses, e.g. Rōma vs. Rōmā
 * Generate conjugations and declensions on-the fly to reduce page load

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
