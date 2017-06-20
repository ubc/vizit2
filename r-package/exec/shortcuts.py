import click as cl


@cl.command()
@cl.argument('shortcut')
def get_shortcut(shortcut):
    if shortcut in SHORTCUT_DICT:
        print(SHORTCUT_DICT[shortcut])
    else:
        print('False')

SHORTCUT_DICT = {'marketing': 'UBCx__Marketing1x__3T2015',
                 'usegen': 'UBCx__UseGen_2x__1T2016',
                 'climate': 'UBCx__Climate1x__2T2016',
                 'spd1': 'UBCx__SPD1x__2T2016',
                 'psyc1': 'UBCx__PSYC_1x__3T2016',
                 'creative_writing': 'UBCx__CW1_1x__1T2016'}


if __name__ == '__main__':
    get_shortcut()
