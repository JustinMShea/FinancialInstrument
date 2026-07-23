#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"
LIB="$ROOT/revdep-library"
SRC="$ROOT/revdep-src"

rm -rf "$LIB" "$SRC"
mkdir -p "$LIB" "$SRC"

export R_LIBS_USER="$LIB"

# Build and install the current FinancialInstrument branch
R CMD build .
FI_TARBALL=$(ls -t FinancialInstrument_*.tar.gz | head -1)
R CMD INSTALL --library="$LIB" "$FI_TARBALL"

# blotter
git clone --depth 1 \
  https://github.com/braverock/blotter.git \
  "$SRC/blotter"

R CMD build "$SRC/blotter"
BLOTTER_TARBALL=$(ls -t blotter_*.tar.gz | head -1)
R CMD check --no-manual "$BLOTTER_TARBALL"
R CMD INSTALL --library="$LIB" "$BLOTTER_TARBALL"

# quantstrat
git clone --depth 1 \
  https://github.com/braverock/quantstrat.git \
  "$SRC/quantstrat"

R CMD build "$SRC/quantstrat"
QUANTSTRAT_TARBALL=$(ls -t quantstrat_*.tar.gz | head -1)
R CMD check --no-manual "$QUANTSTRAT_TARBALL"
