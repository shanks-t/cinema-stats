from setuptools import find_packages, setup

setup(
    name="dagster",
    packages=find_packages(exclude=["pipeline_tests"]),
    install_requires=[
        "dagster",
    ],
    extras_require={"dev": ["dagster-webserver", "pytest"]},
)
