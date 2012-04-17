#!/bin/bash
#
# Purpose:
# Select a random word from a specified word list and
# send it, with definition if available, to an XMPP (jabber/gtalk)
# recipient.
#
# Usage:
# Intended to be triggered by a 'Buddy Pounce' in Pidgin. For example,
# when a certain user comes online. Given a large enough list of words,
# a randomly selected one is usually obscure and fairly entertaining.
# PUDDENING, for example. The act of becoming a pudding? perhaps.
#
# Seriousness:
# Very low
# 
# Dependencies:
#	GNU coreutils
#   libpurple-bin
#   html2text
#   curl
#

# e.g. "steve@gmail.com"
VICTIM="account@xmpp-server.com"

# Specify a big list of words
DICT="/usr/local/share/dict/all-p"

# Select a random word. We do not need "cryptographic" randomness, so /dev/urandom is 
# specified. This prevents emptying the entropy pool, which is annoying for things
# needing real randomness, and also means we'd have to wait.
# 
# It is acknowledged that it would be much more efficient to generate a random number 
# falling within 0 < RAND < word-count than sorting randomly and selecting the last
# word.
WORD="$(sort --random-sort --random-source=/dev/urandom < "$DICT" \
	| tail -n 1 \
	| tr [:lower:] [:upper:])"

# We need a lowercase copy of the word for constructing a URL
WORD_LOWER="$(echo "${WORD}" | tr [:upper:] [:lower:])"

# Ping wiktionary to see if there's a definition for this word. Extracting the definition 
# is a bit hax and not always reliable.
DEFINITION="$(/usr/bin/curl -s -A 'Mozilla/4.0'  "http://en.wiktionary.org/wiki/${WORD_LOWER}" \
	| html2text -width 1000 \
	| egrep -o '[0-9]\. .*$')"

# Construct IM
if [ -z "$DEFINITION" ]; then
	MESSAGE="$WORD"
else
	MESSAGE="$WORD (${DEFINITION})"
fi

# Hand to Pidgin
purple-remote "xmpp:goim?screenname=${VICTIM}&message=${MESSAGE}"
