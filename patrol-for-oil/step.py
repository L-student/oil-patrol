#!/usr/bin/env python
"""
Script to test GNOME with long island sound data
"""
import os
import sys
import shutil
from datetime import datetime, timedelta
import numpy as np
from gnome import scripting
from gnome.basic_types import datetime_value_2d
from gnome.utilities.remote_data import get_datafile
from gnome.model import Model
from gnome.maps import MapFromBNA
from gnome.environment import Wind, Tide
from gnome.spills import Spill
from gnome.spills.release import release_from_splot_data
from gnome.persist import load
from gnome.spills.substance import GnomeOil
from gnome.spills.initializers import plume_initializers
from gnome.utilities.distributions import UniformDistribution
from gnome.movers import RandomMover, CurrentMover, c_GridWindMover
from gnome.outputters import Renderer
from gnome.outputters import NetCDFOutput
from gnome import utilities
from gnome.environment.water import Water
from gnome.spills.release import Release

base_dir = os.path.dirname(__file__)

def make_model(images_dir=os.path.join(base_dir, 'images2')):
    print('initializing the model')
    start_time = datetime(int(sys.argv[1]), int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4]), int(sys.argv[5]))
    mapfile = get_datafile(os.path.join(base_dir, './brazil-coast.bna'))
    gnome_map = MapFromBNA(mapfile, refloat_halflife=6)  # hours
    duration = timedelta(minutes=5)
    timestep = timedelta(minutes=5)
    endtime = start_time + duration
    steps = duration.total_seconds() / timestep.total_seconds()
    print("Total step: %.4i " % (steps))
    model = Model(start_time=start_time,
                  duration=duration, time_step=timestep,
                  map=gnome_map, uncertain=False, cache_enabled=False)
    
    wind = Wind(timeseries=[(start_time, (10, 45))], units='m/s')
    model.environment += wind
    
    water = Water(temperature=25, salinity=35, units={'temperature': 'C'})
    model.environment += water
    
    # oil_name = 'oil_6'
    # oil_name = 'oil_4'
    # oil_name = 'oil_ans_mp'
    # oil_name = 'oil_bahia'
    # oil_name = 'oil_benzene'
    oil_name = 'oil_crude'
    # oil_name = 'oil_diesel'
    # oil_name = 'oil_gas'
    # oil_name = 'oil_jetfuels'
    wd = UniformDistribution(low=.0002, high=.0002)
    subs = GnomeOil( oil_name, water)
    
    print('adding particles')
    num_particles_1 = 50000  # Aumente este valor para adicionar mais partículas
    num_particles_2 = 50000
    if int(sys.argv[6]) == 1:
        release = release_from_splot_data(start_time, 'contiguous.txt')
        release.num_elements = num_particles_1
        print("Adding new particles")
        model.spills += Spill(num_elements=num_particles_1, release=release, substance=subs)
        # model.spills.num_elements=10000
        # num_elements_to_release(current_time, time_step)
    
    try:
        with open('step.txt') as f:
            pos = np.loadtxt('step.txt')
            if pos.ndim == 1 or pos.shape[1] < 3:
                raise ValueError("O arquivo step.txt deve conter pelo menos três colunas.")
            release2 = release_from_splot_data(start_time, 'step.txt')
            release2.num_elements = num_particles_2
            model.spills += Spill(num_elements=num_particles_2,release=release2, substance=subs)
    except IOError:
        print('No previous step, using only contiguous.txt')
    except ValueError as e:
        print(f"Erro no formato do arquivo step.txt: {e}")
    
    print('adding a RandomMover:')
    model.movers += RandomMover(diffusion_coef=500)  
    
    print('adding a current mover:')
    curr_file = get_datafile(os.path.join(base_dir, 'corrente15a28de09.nc'))
    model.movers += CurrentMover(curr_file)
    model.spills.num_elements=10000
    print('adding a grid wind mover:')
    wind_file = get_datafile(os.path.join(base_dir, 'vento15a28de09.nc'))
    w_mover = c_GridWindMover(wind_file)
    # model.environment += wind_file
    w_mover.uncertain_speed_scale = 1.5
    w_mover.uncertain_angle_scale = 0.5  # default is .4
    w_mover.wind_scale = 2
    model.movers += w_mover
    
    print('adding outputters')
    renderer = Renderer(mapfile, images_dir, image_size=(900, 600),
                        output_timestep=timestep,
                        draw_ontop='forecast')
    # renderer.viewport = ((-37, -11), (-34, -8))
    renderer.viewport = ((-37, -11), (-34, -8)) #alagoas
    # renderer.viewport = ((-55, -34), (-30, 5)) #1/4 N alagoas
    # renderer.viewport = ((-35.2845, -9.3341), (-34.8947, -8.9265)) #alagoas
    model.outputters += renderer
    
    netcdf_file = os.path.join(base_dir, 'step.nc')
    scripting.remove_netcdf(netcdf_file)
    model.outputters += NetCDFOutput(netcdf_file, which_data='standard', surface_conc='kde')
    
    return model

if __name__ == '__main__':
    scripting.make_images_dir()
    model = make_model()
    for step in model:
        print("step: %.4i -- memuse: %fMB" % (step['step_num'], utilities.get_mem_use()))
