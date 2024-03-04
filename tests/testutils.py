# Copyright 2020-2021 Collabora Ltd.
#
# SPDX-License-Identifier: MIT

import subprocess

try:
    import typing
except ImportError:
    pass
else:
    typing      # placate pyflakes


class MyCompletedProcess:
    """
    A minimal reimplementation of subprocess.CompletedProcess from
    Python 3.5+, so that some tests can be run on the Python 3.4
    interpreter in Debian 8 'jessie', SteamOS 2 'brewmaster' and
    Ubuntu 14.04 'trusty'.
    """

    def __init__(
        self,
        args='',                # type: typing.Union[typing.List[str], str]
        returncode=-1,          # type: int
        stdout=None,            # type: typing.Optional[bytes]
        stderr=None             # type: typing.Optional[bytes]
    ) -> None:
        self.args = args
        self.returncode = returncode
        self.stdout = stdout
        self.stderr = stderr

    def check_returncode(self) -> None:
        if self.returncode != 0:
            raise subprocess.CalledProcessError(
                self.returncode,
                str(self.args),
                output=self.stdout,
            )


def run_subprocess(
    args,           # type: typing.Union[typing.List[str], str]
    capture_output=False,
    check=False,
    input=None,     # type: typing.Optional[bytes]
    timeout=None,   # type: typing.Optional[int]
    **kwargs        # type: typing.Any
):
    """
    This is basically a reimplementation of subprocess.run()
    from Python 3.5+, so that some tests can be run on the Python
    3.4 interpreter in Debian 8 'jessie', SteamOS 2 'brewmaster'
    and Ubuntu 14.04 'trusty'.
    """

    if capture_output:
        kwargs['stdout'] = -1
        kwargs['stderr'] = -1

    popen = subprocess.Popen(args, **kwargs)    # type: ignore
    out, err = popen.communicate(input=input, timeout=timeout)
    completed = MyCompletedProcess(
        args=args,
        returncode=popen.returncode,
        stdout=out,
        stderr=err,
    )

    if check:
        completed.check_returncode()

    return completed
