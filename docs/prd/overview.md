# Red Taxi Platform - Overview

## Executive Summary

Red Taxi Platform is a ground-up rebuild of the Ace Taxis dispatch system, transforming it from a single-tenant application into a scalable multi-tenant SaaS platform. The system handles the complete taxi operations lifecycle: booking creation, dispatch, driver management, pricing, payments, messaging, and reporting.

## Problem Statement

Existing taxi dispatch systems (iCabbi, Autocab, Cordic) are:
- Expensive with per-driver licensing
- Difficult to customise
- Poor integration capabilities
- Limited multi-company support
- Not designed for modern AI features

## Solution

A modern, cloud-native taxi dispatch platform that:
- Operates as multi-tenant SaaS
- Supports single operators to large fleets
- Enables subcontracting and job sharing
- Is AI-ready from day one
- Offers competitive pricing

## Key Differentiators

1. **True Multi-tenancy** - Shared infrastructure with isolated data
2. **AI-First Design** - Architecture supports voice booking, smart dispatch, demand forecasting
3. **Modern API** - Full REST API for integrations
4. **Real-time Everything** - SignalR for instant updates
5. **Transparent Pricing** - No per-driver licensing traps

## Target Market

- Independent taxi operators (5-50 drivers)
- Medium fleets (50-200 drivers)
- Multi-company operations
- School/social care transport providers
- Airport transfer specialists

## Success Metrics

- Booking creation < 30 seconds
- Auto-dispatch success rate > 85%
- System uptime > 99.9%
- Driver app response time < 2 seconds
- Operator satisfaction score > 4.5/5

## Related Documents

- [Product Vision](product-vision.md)
- [System Scope](system-scope.md)
- [Roadmap](roadmap.md)
