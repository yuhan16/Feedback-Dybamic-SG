#import parameters as pm
from sg_utils import DiscountedStackelbergGame, PlotUtils

def test():
    sg = DiscountedStackelbergGame()
    va, vb, pia, pib = sg.backward_dp()

def main():
    s0 = 0  # first state
    sg = DiscountedStackelbergGame()
    pltutil = PlotUtils()

    va, vb, pia, pib = sg.backward_dp()
    pltutil.plot_value(va, vb, [0,2,3,4])
    #pltutil.plot_policy(piA, piB, T)


if __name__ == "__main__":
    main()
    