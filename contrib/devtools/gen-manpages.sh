#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

SCHOLARSHIPCOIND=${SCHOLARSHIPCOIND:-$SRCDIR/scholarshipcoind}
SCHOLARSHIPCOINCLI=${SCHOLARSHIPCOINCLI:-$SRCDIR/scholarshipcoin-cli}
SCHOLARSHIPCOINTX=${SCHOLARSHIPCOINTX:-$SRCDIR/scholarshipcoin-tx}
SCHOLARSHIPCOINQT=${SCHOLARSHIPCOINQT:-$SRCDIR/qt/scholarshipcoin-qt}

[ ! -x $SCHOLARSHIPCOIND ] && echo "$SCHOLARSHIPCOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
SCHOVER=($($SCHOLARSHIPCOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$SCHOLARSHIPCOIND --version | sed -n '1!p' >> footer.h2m

for cmd in $SCHOLARSHIPCOIND $SCHOLARSHIPCOINCLI $SCHOLARSHIPCOINTX $SCHOLARSHIPCOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${SCHOVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${SCHOVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
