import subprocess
import threading
import signal
import shlex
import os
import queue
import ctypes
import tkinter as tk
from datetime import datetime
from subprocess import Popen, PIPE
from time import sleep
from tkinter import *


title_1A = '1A\n\niPerf Client 127.0.0.1'
log_1A = 'log_1A_iperf_client.txt'
command_1A = '/Apps/iperf-2.0.9-win64/iperf.exe -c 127.0.0.1 -p 12345 -u -b 50pps -l 140 -i 1 -t 30'

title_1B = '1B\n\nPing 127.0.0.1'
log_1B = 'log_1B.txt'
command_1B = 'ping -t 127.0.0.1'

title_1C = '1C\n\nPing 127.0.0.1'
log_1C = 'log_1C.txt'
command_1C = 'ping -t 127.0.0.1'

title_1D = '1D\n\nPing 127.0.0.1'
log_1D = 'log_1D.txt'
command_1D = 'ping -t 127.0.0.1'

title_1E = '1E\n\nPing 127.0.0.1'
log_1E = 'log_1E.txt'
command_1E = 'ping -t 127.0.0.1'

title_2A = '2A\n\niPerf Server 127.0.0.1'
log_2A = 'log_2A_iperf_server.txt'
command_2A = '/Apps/iperf-2.0.9-win64/iperf.exe -s -p 12345 -u -i 1'

title_2B = '2B\n\nPing 127.0.0.1'
log_2B = 'log_2B.txt'
command_2B = 'ping -t 127.0.0.1'

title_2C = '2C\n\nPing 127.0.0.1'
log_2C = 'log_2C.txt'
command_2C = 'ping -t 127.0.0.1'

title_2D = '2D\n\nPing 127.0.0.1'
log_2D = 'log_2D.txt'
command_2D = 'ping -t 127.0.0.1'




# Get HWND numbers and titles for a given PID.
def get_hwnds(pid):
    """return a list of window handlers based on it process id"""
    hwnds = []
    titles = []

    def callback(hwnd, lParam):
        length = ctypes.windll.user32.GetWindowTextLengthW(hwnd)
        buff = ctypes.create_unicode_buffer(length + 1)
        ctypes.windll.user32.GetWindowTextW(hwnd, buff, length + 1)
        windowtitle = buff.value

        processID = ctypes.c_int()
        threadID = ctypes.windll.user32.GetWindowThreadProcessId(hwnd,ctypes.byref(processID))
        found_pid = processID.value
        if found_pid == pid:
            hwnds.append(hwnd)
            titles.append(windowtitle)

    EnumWindowsProc = ctypes.WINFUNCTYPE(ctypes.c_bool, ctypes.POINTER(ctypes.c_int), ctypes.POINTER(ctypes.c_int))

    ctypes.windll.user32.EnumWindows(EnumWindowsProc(callback), 0)
    return hwnds, titles

# Ref:
# http://pixomania.net/programming/python-getting-the-title-of-windows-getting-their-processes-and-their-commandlines-using-ctypes-and-win32/

class Console(tk.Frame):
    def __init__(self, master, *args, **kwargs):
        tk.Frame.__init__(self, master, *args, **kwargs)

        self.grid_propagate(False)
        self.grid_rowconfigure(0, weight=1)
        self.grid_columnconfigure(0, weight=1)

        # Create the title text widget
        self.title_text = tk.Text(self, borderwidth=3, height=1, wrap='none')

        self.title_text.grid(row=0, column=0, columnspan=2, sticky="ew", padx=2,pady=2)
        self.rowconfigure(0, weight=0)

        # Create the horiz scroll bar widget for the title text
        self.title_xscrollb = tk.Scrollbar(self, orient='horizontal', command=self.title_text.xview)
        self.title_xscrollb.grid(row=1, column=0, columnspan=2, sticky="nsew")
        self.title_text['xscrollcommand'] = self.title_xscrollb.set
        self.rowconfigure(1, weight=0)

        # Create the log file text widget
        self.log_text = tk.Text(self, borderwidth=3, height=1, wrap='none')

        self.log_text.grid(row=2, column=0, columnspan=2, sticky="ew", padx=2,pady=2)
        self.rowconfigure(2, weight=0)

        # Create the horiz scroll bar widget for the title text
        self.log_xscrollb = tk.Scrollbar(self, orient='horizontal', command=self.log_text.xview)
        self.log_xscrollb.grid(row=3, column=0, columnspan=2, sticky="nsew")
        self.log_text['xscrollcommand'] = self.log_xscrollb.set
        self.rowconfigure(3, weight=0)

        # Create the text widget
        self.text = tk.Text(self, borderwidth=3, relief="sunken", undo=False, wrap='none')
        self.text.grid(row=4, column=0, columnspan=2, sticky="nsew", padx=2,pady=2)
        self.rowconfigure(4, weight=1)

        # Create the vertical scroll bar widget
        self.scrollb = tk.Scrollbar(self, command=self.text.yview)
        self.scrollb.grid(row=4, column=3, sticky="nsew")
        self.text['yscrollcommand'] = self.scrollb.set
        self.columnconfigure(3, weight=0)

        # Create the horiz scroll bar widget for the text
        self.xscrollb = tk.Scrollbar(self, orient='horizontal', command=self.text.xview)
        self.xscrollb.grid(row=5, column=0, columnspan=2, sticky="nsew")
        self.text['xscrollcommand'] = self.xscrollb.set
        self.rowconfigure(5, weight=0)

        # Create a button to run the process
        self.runb = tk.Button(self, text="Run", command=self.run_button, state='normal')
        self.runb.grid(row=6,column=0, sticky="nsew")
        self.columnconfigure(0, weight=1)

        # Create a button to stop the process
        self.stopb = tk.Button(self, text="Stop", command=self.stop_button, state='disabled')
        self.stopb.grid(row=6,column=1, sticky="nsew")
        self.rowconfigure(6, weight=0)
        self.columnconfigure(1, weight=1)

        # create placeholder for the process p
        self.process_args = None
        self.p = None
        self.p_hwnd = None
        self.stop_flag = False

        # create placeholder for the log file
        self.f_logname = None
        self.f_log = None

        # Queue for feeding new text into the text widget
        self.text_queue = queue.SimpleQueue()

        # Queue for text lines to be logged
        self.log_queue = queue.SimpleQueue()

        # Queue for feeding new look and feel to the button widget
        self.stop_button_queue = queue.SimpleQueue()

        # Queue for feeding new look and feel to the button widget
        self.run_button_queue = queue.SimpleQueue()

        self.line_num = 0

        self.start_event = threading.Event()
        self.start_event.clear()

        self.start_reading_event = threading.Event()
        self.start_reading_event.clear()

        self.start_datetime = None

        self.read_std_active = threading.Event()
        self.read_std_active.clear()

        self.read_err_active = threading.Event()
        self.read_err_active.clear()

        self.write_log_active = threading.Event()
        self.write_log_active.clear()

        self.start_logging_event = threading.Event()
        self.start_logging_event.clear()

        self.stop_logging_event = threading.Event()
        self.stop_logging_event.clear()

        self.stop_event = threading.Event()
        self.stop_event.clear()

        self.destroy_event = threading.Event()
        self.destroy_event.clear()

        # Register the Queue Processor
        self.after(50, self.queue_processor)

        # run the "start stop" controller thread
        t = threading.Thread(target=self.t_process_start_stop)
        t.start()

        # run the "write the log" thread to write everything that is shown on screen
        write_log_thread = threading.Thread(target=self.t_write_log)
        write_log_thread.start()

        # run the "read the pipe" thread to process stdout from the process
        # and put into the text update queue.
        read_thread = threading.Thread(target=self.t_read_the_pipe)
        read_thread.start()

        # run the "read the pipe" thread to process stdout from the process
        # and put into the text update queue.
        read_err_thread = threading.Thread(target=self.t_read_err_pipe)
        read_err_thread.start()

    def destroy(self):
        self.destroy_event.set()
        self.stop_event.set()
        sleep(1)
        tk.Frame.destroy(self)

    def run_button(self):
        self.process_args = shlex.split(self.title_text.get("1.0",END).strip())
        self.f_logname = self.log_text.get("1.0",END).strip()
        self.start_event.set()

    def stop_button(self):
        self.stop_event.set()

    def queue_processor(self):
        try:
            stop_button_config_arg = self.stop_button_queue.get_nowait()
            self.stopb.config(**stop_button_config_arg)
        except queue.Empty:
            pass

        try:
            run_button_config_arg = self.run_button_queue.get_nowait()
            self.runb.config(**run_button_config_arg)
        except queue.Empty:
            pass

        try:
            limit=100  # Set a limit for how many items will be serviced from the queue before giving control back to the main loop.
            while limit > 0:
                line = self.text_queue.get_nowait()

                # Send to the log file whatever was queued to be written to the text box
                if self.start_logging_event.is_set() or self.write_log_active.is_set():
                    self.log_queue.put(line)

                # Write the line from the text box queue to the text box
                self.text.insert(END, line)

                # If the scroll bar is very close to the bottom then automatically scroll the window
                # but don't scroll it if the user had moved the scroll bar up, or across, to look at something
                if self.scrollb.get()[1] > 0.992 and self.xscrollb.get()[0] < 0.008:
                    self.text.see(END)
                limit = limit-1
        except queue.Empty:
            pass

        self.after(100, self.queue_processor)

    def open_process(self, new_process):
        self.title_text.delete("1.0", END)
        self.title_text.insert(END, new_process)
        self.process_args = shlex.split(self.title_text.get("1.0",END))
        self.stop_event.set()
        self.start_event.set()

    def set_process(self, new_process):
        self.title_text.delete("1.0", END)
        self.title_text.insert(END, new_process)

    def set_log(self, new_log):
        self.log_text.delete("1.0", END)
        self.log_text.insert(END, new_log)


    def t_read_the_pipe(self):
        while not self.destroy_event.is_set():
            if self.start_reading_event.wait(1) and not self.p is None:
                self.read_std_active.set()
                self.start_reading_event.clear()
                line_num = 0
                elapsed_time = None
                for line in self.p.stdout:
                    line_num += 1
                    elapsed_time = datetime.utcnow() - self.start_datetime
                    prefix = '{:010.3f} - '.format(elapsed_time.total_seconds())
#                    prefix = '{:04d}-{:%Y%m%d-%H%M%S} '.format(line_num,datetime.now())
                    self.text_queue.put(prefix+line)
                    self.p.stdout.flush()
                line = ":: STOP :: (-) Lines on stdout " + str(line_num) + " ::\n"
                line = line + ":: STOP :: (-) UTC " + datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S.%f')[:-3] + " ::\n"
                self.text_queue.put(line)

                self.read_std_active.clear()
                self.stop_event.set()

    def t_read_err_pipe(self):
        while not self.destroy_event.is_set():
            if self.start_reading_event.wait(1) and not self.p is None:
                self.read_err_active.set()
                line_num = 0
                elapsed_time = None
                for line in self.p.stderr:
                    line_num += 1
                    elapsed_time = datetime.utcnow() - self.start_datetime
                    prefix = '{:010.3} ! '.format(elapsed_time.total_seconds())
                    #prefix = 'ERR-{:04d}-{:%Y%m%d-%H%M%S} '.format(line_num,datetime.now())
                    self.text_queue.put(prefix+line)
                    self.p.stderr.flush()
                line = ":: STOP :: (!) Lines on stderr " + str(line_num) + " ::\n"
                line = line + ":: STOP :: (!) UTC " + datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S.%f')[:-3] + " ::\n"
                self.text_queue.put(line)

                self.read_err_active.clear()

    def t_write_log(self):
        while not self.destroy_event.is_set():
            if self.start_logging_event.wait(1) and not self.f_log is None and not self.f_log.closed:
                self.write_log_active.set()
                self.start_logging_event.clear()
                while not self.stop_logging_event.is_set() and not self.f_log.closed:
                    try:
                        line = self.log_queue.get(True, 1)
                        self.f_log.write(line)
                        if line.strip() == "<<<< LOGGING STOPPED >>>>":
                            self.stop_logging_event.set()
                            break
                    except queue.Empty:
                        pass
                self.f_log.close()
                self.write_log_active.clear()

    def t_process_start_stop(self):
        while not self.destroy_event.is_set():
            if self.stop_event.wait(1):
                if self.p is None:
                    self.stop_event.clear()
                else:
                    if self.p.poll() is None:
                        if hasattr(os.sys, 'winver'):
                            if not self.p_hwnd is None:
                                ctypes.windll.user32.SendMessageW(self.p_hwnd, 0x0010, 0,0)
                        else:
                            self.p.send_signal(signal.SIGTERM)
                    limit = 1
                    while self.p.poll() is None and limit > 0:
                        sleep(1)
                        self.p.terminate()
                        limit = limit - 1
                    limit = 2
                    while self.p.poll() is None and limit > 0:
                        sleep(1)
                        self.p.kill()
                        limit = limit - 1

                    if not self.p.poll() is None:
                        self.text_queue.put(":: STOP :: Exit code " + str(int(self.p.poll())) + " ::\n")
                        if self.start_logging_event.is_set() or self.write_log_active.is_set():
                            self.text_queue.put("<<<< LOGGING STOPPED >>>>\n")
                        self.stop_event.clear()
                        self.stop_button_queue.put({'state': 'disabled', 'text': 'Exitcode {}'.format(int(self.p.poll()))})
                        self.run_button_queue.put({'state': 'normal'})

            if not self.stop_event.is_set() and self.start_event.is_set():
                self.start_event.clear()

                # Clear out the log queue
                try:
                    while True:
                        _ = self.log_queue.get_nowait()
                except queue.Empty:
                    pass

                if not self.f_logname is None and len(self.f_logname) > 0:
                    try:
                        prefix = '{:%Y%m%d-%H%M%S} '.format(datetime.now())
                        openname = prefix+self.f_logname
                        self.f_log = open(openname, "w+")

                        self.text_queue.put("<<<< LOGGING TO \""+openname+"\" >>>>\n")

                        self.stop_logging_event.clear()
                        self.start_logging_event.set()

                    except:
                        self.text_queue.put(':: ERROR :: Could not open log file '+openname+' ::\n')
                        self.text_queue.put(':: ERROR :: '+str(sys.exc_info()[0])+'\n')


                if self.p is None or not self.p.poll() is None:
                    self.text_queue.put(":: START :: " + ' '.join(self.process_args) + " ::\n")

                    self.start_datetime = datetime.utcnow()

                    self.text_queue.put(":: START :: UTC " + self.start_datetime.strftime('%Y-%m-%d %H:%M:%S.%f')[:-3] + " ::\n")

                    try:
                        if hasattr(os.sys, 'winver'):
    #                        startupinfo = subprocess.STARTUPINFO()
    #                        startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW

                            self.p = Popen(self.process_args,
    #                                       startupinfo=startupinfo,
    #                                       creationflags=subprocess.CREATE_NEW_CONSOLE | subprocess.CREATE_NEW_PROCESS_GROUP,
                                           creationflags= subprocess.CREATE_NEW_PROCESS_GROUP,
                                           universal_newlines=True,
                                           stdout=PIPE, stderr=PIPE)
                        else:
                            self.p = Popen(self.process_args,
                                           universal_newlines=True,
                                           stdout=PIPE, stderr=PIPE)

                        self.text_queue.put(":: START :: Process ID " + str(self.p.pid) + " ::\n")
                        self.stop_button_queue.put({'state': 'normal', 'text': 'STOP PID {}'.format(self.p.pid)})
                        self.run_button_queue.put({'state': 'disabled'})
                        self.start_reading_event.set()

                        if hasattr(os.sys, 'winver'):
                            sleep(1)
                            hwnds, titles = get_hwnds(self.p.pid)

                            if len(hwnds) > 0:
                                self.p_hwnd = hwnds[0]
                                # Send a Minimize instruction to the console window which got opened up (in Windows)
                                ctypes.windll.user32.ShowWindow(self.p_hwnd, 6)
                            else:
                                hwnds = None
                    except:
                        self.text_queue.put(':: ERROR :: Could not start process ::\n')
                        self.text_queue.put(':: ERROR :: '+str(sys.exc_info()[0])+'\n')
                        if self.start_logging_event.is_set() or self.write_log_active.is_set():
                            self.text_queue.put("<<<< LOGGING STOPPED >>>>\n")



def press_1A():
    console_1.set_process(command_1A)
    console_1.set_log(log_1A)
    pass

def press_1B():
    console_1.set_process(command_1B)
    console_1.set_log(log_1B)
    pass

def press_1C():
    console_1.set_process(command_1C)
    console_1.set_log(log_1C)
    pass

def press_1D():
    console_1.set_process(command_1D)
    console_1.set_log(log_1D)
    pass

def press_1E():
    console_1.set_process(command_1E)
    console_1.set_log(log_1E)
    pass

def press_2A():
    console_2.set_process(command_2A)
    console_2.set_log(log_2A)
    pass

def press_2B():
    console_2.set_process(command_2B)
    console_2.set_log(log_2B)
    pass

def press_2C():
    console_2.set_process(command_2C)
    console_2.set_log(log_2C)
    pass

def press_2D():
    console_2.set_process(command_2D)
    console_2.set_log(log_2D)
    pass


if __name__ == "__main__":
    root = tk.Tk()
    root.geometry('800x600+0+0')
    root.attributes('-fullscreen', True)

    root.title("Ping Test")
    console_1 = Console(root)
    console_2 = Console(root)

    console_1.grid(row=0, rowspan=5, column=1, sticky="nsew")
    console_2.grid(row=0, rowspan=5, column=3, sticky="nsew")

    button_1a = tk.Button(root, text=title_1A, command=press_1A, state='normal')
    button_1b = tk.Button(root, text=title_1B, command=press_1B, state='normal')
    button_1c = tk.Button(root, text=title_1C, command=press_1C, state='normal')
    button_1d = tk.Button(root, text=title_1D, command=press_1D, state='normal')
    button_1e = tk.Button(root, text=title_1E, command=press_1E, state='normal')

    button_2a = tk.Button(root, text=title_2A, command=press_2A, state='normal')
    button_2b = tk.Button(root, text=title_2B, command=press_2B, state='normal')
    button_2c = tk.Button(root, text=title_2C, command=press_2C, state='normal')
    button_2d = tk.Button(root, text=title_2D, command=press_2D, state='normal')
    button_2e = tk.Button(root, text="EXIT", command=root.destroy, state='normal')

    button_1a.grid(row=0,column=0, sticky="nsew")
    button_1b.grid(row=1,column=0, sticky="nsew")
    button_1c.grid(row=2,column=0, sticky="nsew")
    button_1d.grid(row=3,column=0, sticky="nsew")
    button_1e.grid(row=4,column=0, sticky="nsew")

    button_2a.grid(row=0,column=2, sticky="nsew")
    button_2b.grid(row=1,column=2, sticky="nsew")
    button_2c.grid(row=2,column=2, sticky="nsew")
    button_2d.grid(row=3,column=2, sticky="nsew")
    button_2e.grid(row=4,column=2, sticky="nsew")

    root.grid_rowconfigure(0, weight=1)
    root.grid_rowconfigure(1, weight=1)
    root.grid_rowconfigure(2, weight=1)
    root.grid_rowconfigure(3, weight=1)
    root.grid_rowconfigure(4, weight=1)

    root.grid_columnconfigure(0, weight=1)
    root.grid_columnconfigure(1, weight=5)
    root.grid_columnconfigure(2, weight=1)
    root.grid_columnconfigure(3, weight=5)

    root.mainloop()
