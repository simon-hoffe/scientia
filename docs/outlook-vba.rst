.. //> vim: set tw=0

.. index::
   single: outlook
   single: vba

Outlook VBA Scripts
===================

Introduction
------------

This VBA Module provides a feature to write a selection of emails to disk, such that the .msg file is named with date_sent -- sender -- subject and the visible attachments are saved alongside the file with the same date_sent as a prefix.

The .msg file and the associated attachments have their modified timestamp set to the sent timestamp.

The email in the Outlook Mailbox has the category "saved" added to it, so that messages which have already been saved can be kept track of.

Repository on GitHub: `outlook-vba <https://github.com/simon-hoffe/scientia/tree/master/outlook-vba>`_.

With thanks to Chip Pearson, `www.cpearson.com <http://www.cpearson.com>`_, chip@cpearson.com for his file timestamp get/set VBA functions.


Source
------
.. literalinclude:: ../outlook-vba/modEmailExport.bas
   :language: vbnet
   :linenos:

.. //> http://pygments.org/docs/lexers/
