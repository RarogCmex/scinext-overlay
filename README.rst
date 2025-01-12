scinext-overlay
===============

.. image:: favicon.webp
        :width: 200 px
        :align: center
        :alt: Logotype of the project

The main purpose for this repository is to provide experimental but ready for production packages.

Product Quality
-----------------

If you notice outdated packages, please contact me.

Adding the repository
---------------------

This is actual untill the repo will be added to official overlay index.

Add the repository via:
::

        eselect repository add scinext-overlay git https://github.com/RarogCmex/scinext-overlay.git

Repository's distfiles mirror
---------------------------------

I have recently set up a dedicated Gentoo Distfiles mirror for downloading distfiles, ensuring reliable and fast access to all resources required by the overlay. The mirror is located in Russia, Ufa.

You might want to enable the mirror in your **make.conf**:
::
        GENTOO_MIRRORS="${GENTOO_MIRRORS} https://scinext-overlay-distfiles.imperium.org.ru"


