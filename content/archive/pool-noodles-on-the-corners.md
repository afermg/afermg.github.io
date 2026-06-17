+++
title = "Pool noodles on the corners"
author = ["Alán F. Muñoz"]
date = 2026-06-16T23:14:00-04:00
tags = ["design", "ux", "users", "thoughts"]
categories = ["post"]
draft = false
+++

Today I failed to videocall a prospective landlord. He wanted to FaceTime me to judge whether or not I am an adult who can (and is willing) to pay rent. I explained that FaceTiming my number would not work because I use an Android phone, not an iPhone. Hours later, he replied asking if we were face-timing or not. I explained the issue again and suggested a standard phone call instead. No response. As it turns out, my limited ability to survive in the outdoors is a strong motivator. I rushed home, grabbed my iPad and sent him a FaceTime link telling him I would be waiting. The link appeared to have confused him: "Why can't I just use the phone number?", he asked. Snarky comments raced through my mind: Due to Apple's strangehold of the US mobile market driven by proprietary videocommunication protocols; because Big Tech is determined to rule how our devices ought to be used, reducing the users' freedom to try or implement novel solutions (looking at you Microsoft Office). "Having a roof above my head is nice", a lone thought interrupted the barrage of snobiness. We rescheduled to try again tomorrow.

A couple of things worth noting: 1. He has an AOL email account (it's like a unicorn in the wild). 2. His replies quote not my latest email, but his own previous email and thus the email thread skips all my replies. I would normally consider this sociopathic behaviour. I chose to believe it is unintentional and thus deemed this a battle for another day.

As it happens, earlier today I had a discussion with a colleague the tradeoffs involved in sanitising the users' input for an image-processing library. My argument can be reduced to "Let the math be mathy": Do not add unnecessary logic or sanitation to the parts of the tool that crunch the numbers; it will only increases the [accidental complexity](https://en.wikipedia.org/wiki/No_Silver_Bullet) of the system. This comes from my experience overengineering systems to solve problems that may or may not exist. My colleague's response was: "I just assume all my users are basically babies that'll hit their head whenever I don't put a pool noodle on the corners". After my abject failure at FaceTiming someone, I am defenseless against that logic. We thus agreed to add input sanitation, but isolate it from the data-crunching functions.

Disclaimer: I don't mean to make fun of anyone. Tech illiteracy is a real issue, we should build tools that are accessible and easy to learn. That said: Dear prospective landlord, if you are reading this, I think you would like me as a tenant because I have an unnatural skill to keep Nigerian princes at bay.
