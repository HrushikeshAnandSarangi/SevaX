import getopt
import os
import sys


def runCommand(command):
    print('building '+command)
    os.system(command)


def main(argv):
    platform = ''
    environment = ''
    try:
        platform = argv[0]
        environment = argv[1]

        if environment == 'dev':
            if platform == 'android':
                runCommand(
                    'flutter build apk --flavor dev -t lib/main_seva_dev.dart')
            if platform == 'ios':
                runCommand(
                    'flutter build ios --flavor dev -t lib/main_seva_dev.dart')
            if platform == 'web':
                runCommand('flutter build web -t lib/main_seva_dev.dart')

        if environment == 'prod':
            if platform == 'android':
                runCommand(
                    'flutter build apk --flavor app -t lib/main_app.dart')
            if platform == 'ios':
                runCommand(
                    'flutter build ios --flavor app -t lib/main_app.dart')
            if platform == 'web':
                runCommand('flutter build web -t lib/main_app.dart')

    except IndexError:
        print(
            'pass platform and envirnoment as mentioned\n' +
            'build.py <platform> <environment>\n'
            + 'example: python build.py android dev'
        )
        sys.exit(2)


if __name__ == "__main__":
    main(sys.argv[1:])
