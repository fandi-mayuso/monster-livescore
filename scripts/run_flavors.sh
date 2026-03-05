#!/bin/bash

case "$1" in
  dev)
    # Run dev flavor
    flutter run --flavor dev -t lib/main/main_dev.dart
    ;;
  staging)
    # Run staging flavor
    flutter run --flavor staging -t lib/main/main_staging.dart
    ;;
  prod)
    # Run prod flavor
    flutter run --flavor prod -t lib/main/main_prod.dart
    ;;
  *)
    echo "Usage: ./scripts/run_flavors.sh {dev|staging|prod}"
    echo ""
    echo "Examples:"
    echo "  ./scripts/run_flavors.sh dev"
    echo "  ./scripts/run_flavors.sh staging"
    echo "  ./scripts/run_flavors.sh prod"
    exit 1
    ;;
esac
