#import parameters as pm
from sg_utils import DiscountedStackelbergGame

def test():
    sg = DiscountedStackelbergGame()
    va, vb, pia, pib = sg.backward_dp()

def main():
    s0 = 0  # first state
    sg = DiscountedStackelbergGame()

    va, vb, pia, pib = sg.backward_dp()
    sg.plot_value(va, vb, [0,2,3,4])
    #sg.plot_policy(piA, piB, T)


if __name__ == "__main__":
    main()
    