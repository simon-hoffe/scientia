.. //> vim: set tw=0

.. index::
   single: mql5
   single: mt4
   single: mt5

Metaquotes MT4 and MT5
===================

Introduction
------------

These pages are firstly "notes to self" on setting things up, and will reference private git repositories.

Perhaps, as this matures, I will clean it up for wider consumption.

MT4 Setup
---------

- Install MT4 from the install file provided by the broker

    Modify the destination directory with a (n) suffix to install multiple copies on the same machine

- Git clone the MT4 base repo into a new folder on the machine, then manually copy it across to overlay onto the MQL4 folder in Terminal datadirectory.

::
  git clone https://github.com/simon-hoffe/mql5-mt4-base.git

  git clone git@github.com-personal:simon-hoffe/mql5-mt4-base.git

Then need to initialise the sub-modules and clone them as well.

::
  git submodule update --init --recursive


.. //> http://pygments.org/docs/lexers/
