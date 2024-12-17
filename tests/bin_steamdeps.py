# Copyright 2021 Collabora Ltd.
# SPDX-License-Identifier: MIT

import os
from tempfile import NamedTemporaryFile
import unittest

from testutils import run_subprocess

G_TEST_SRCDIR = os.getenv(
    'G_TEST_SRCDIR',
    os.path.abspath(
        os.path.join(os.path.dirname(__file__), os.pardir),
    ),
)


class SteamdepsTestCase(unittest.TestCase):
    def test_dependencies(self):
        self.maxDiff = None

        # Whitespace separated list
        pkgs_to_install = os.environ.get('SL_TEST_PKGS_TO_INSTALL', '')
        # Whitspace separated list
        missing_pkgs = os.environ.get('SL_TEST_MISSING_PKGS', '')
        required_pkgs = os.environ.get(
            'SL_TEST_REQUIRED_PKGS', '',
        )

        already_installed = os.environ.get(
            'SL_TEST_ALREADY_INSTALLED', ''
        ).split()

        output_message = os.environ.get('SL_TEST_OUTPUT_MESSAGE', '')

        if (
            not pkgs_to_install
            and not missing_pkgs
            and not output_message
            and not required_pkgs
        ):
            raise unittest.SkipTest(
                'At least one of SL_TEST_PKGS_TO_INSTALL, '
                'SL_TEST_REQUIRED_PKGS, '
                'SL_TEST_MISSING_PKGS '
                'or SL_TEST_OUTPUT_MESSAGE needs to be set')

        steamdeps = os.path.join(G_TEST_SRCDIR, "steamdeps")

        with NamedTemporaryFile(mode='w') as tmp_steamdeps:
            # This could be expanded by shipping different steamdeps.txt
            # files to test the parsing of dependencies too
            tmp_steamdeps.write("STEAM_RUNTIME=1\nSTEAM_DEPENDENCY_VERSION=1")
            tmp_steamdeps.flush()

            cp = run_subprocess(
                [steamdeps, "--dry-run", tmp_steamdeps.name],
                capture_output=True,
                universal_newlines=True,
            )

        stdout_list = cp.stdout.splitlines()
        stderr_list = cp.stderr.splitlines()

        for line in stdout_list:
            print('stdout: ' + line)

        for line in stderr_list:
            print('stderr: ' + line)

        self.assertEqual(1, cp.returncode)

        install_pkgs_list = sorted(filter(None, pkgs_to_install.split(' ')))
        # The output is already sorted
        stderr_list = [x for x in stderr_list if x.startswith('Package ')]
        expected = [
            'Package {} needs to be installed'.format(pkg)
            for pkg in install_pkgs_list
            if pkg not in already_installed
        ]

        self.assertEqual(expected, stderr_list)

        for line in stdout_list:
            if line.startswith('Would run: apt-get ') and required_pkgs:
                prefix = (
                    'Would run: apt-get install --no-remove '
                    '-oAPT::Get::AutomaticRemove=false '
                )
                self.assertEqual(prefix, line[:len(prefix)])
                expected = sorted(required_pkgs.split())
                would_install = sorted(line[len(prefix):].split())
                self.assertEqual(expected, would_install)
                break
        else:
            if required_pkgs:
                raise AssertionError(
                    '"Would run: apt-get" not found on stdout'
                )

        # Allow missing packages to appear here more than once to make it
        # easier to write the tests, and use a set to uniquify
        missing_pkgs_list = sorted(set(filter(None, missing_pkgs.split(' '))))
        # The output is already sorted
        stdout_list = [x for x in stdout_list if x.startswith('- ')]
        expected = ['- {}'.format(pkg) for pkg in missing_pkgs_list]
        self.assertEqual(expected, stdout_list)

        if output_message:
            self.assertIn(output_message, cp.stdout)


if __name__ == '__main__':
    unittest.main()
