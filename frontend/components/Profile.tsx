"use client"
import React, { useState, ChangeEvent, FormEvent, MouseEvent, useEffect } from 'react'
import { AiOutlineEye, AiOutlineEyeInvisible } from 'react-icons/ai';
import logo from "../public/images/logo.png";
import Image from 'next/image';
import * as fcl from "@onflow/fcl";
import "../flow/config";



const Profile = () => {

    const [isScrollingUp, setIsScrollingUp] = useState(false);

    const [formData, setFormData] = useState<{
        FirstName: string;
        MiddleName: string;
        LastName: string;
        email: string;
        github: string;
        country: string;
        state: string;
        address: string;
        phone: string;
        confirmPassword: string;
        password: string;

    }>({

        FirstName: '',
        LastName: '',
        github:'',
        MiddleName:'',
        email: '',
        country: '',
        state: '',
        address: '',
        phone: '',
       confirmPassword: '',
        password: '',
    

    });

    const [passwordError, setPasswordError] = useState(false);
    const [showPassword, setShowPassword] = useState(false);
    const [showConfirmPassword, setShowConfirmPassword] = useState(false);
    const [submittedData, setSubmittedData] = useState<{
        FirstName: string;
        MiddleName: string;
        LastName: string;
        email: string;
        maiden: string;
        country: string;
        state: string;
        address: string;
        phone: string;
    } | null>(null);


    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        setFormData({
            ...formData,
            [e.target.name]: e.target.value
        });
    };


    const toggleShowPassword = () => {
        setShowPassword(!showPassword);
    };

    const toggleShowConfirmPassword = () => {
        setShowConfirmPassword(!showConfirmPassword);
    };

    const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault();
        if (formData.password !== formData.confirmPassword) {
            setPasswordError(true);
            return;
        }

        // Simulating form submission success
        setSubmittedData({ ...formData });

        // Handle form submission logic here
        const addProfile = async () => {
        const wallet = await fcl.logIn();
        console.log({ wallet });
        console.log(wallet.addr);
        console.log(
            {
                "walletAddress": `${wallet.addr}`,
                "FirstName": `${formData.FirstName}`,
                "MiddleName": `${formData.MiddleName}`,
                "LastName": `${formData.LastName}`,
                "email": `${formData.email}`,
                "GitHub": `${formData.github}`,
                "country": `${formData.country}`,
                "state":   `${formData.state}`,
                "address": `${formData.address}`,
                "phone": `${formData.phone}`
        }
        );

        await fetch('http://16.170.224.207/profile', {
            method: 'POST',
            body: JSON.stringify({
                    "walletAddress": `${wallet.addr}`,
                    "FirstName": `${formData.FirstName}`,
                    "MiddleName": `${formData.MiddleName}`,
                    "LastName": `${formData.LastName}`,
                    "email": `${formData.email}`,
                    "GitHub": `${formData.github}`,
                    "country": `${formData.country}`,
                    "state":   `${formData.state}`,
                    "address": `${formData.address}`,
                    "phone": `${formData.phone}`
            }),
            headers: {
            'Content-type': 'application/json; charset=UTF-8',
            },
            })
            .then((response) => response.json())
            .then((data) => {
                console.log(data);
            })
            .catch((err) => {
            console.log(err.message);
            });
        }
        console.log(formData);
        addProfile();
        // Reset the form
        setFormData({
            FirstName: '',
            LastName: '',
            github: '',
            MiddleName: '',
            email: '',
            country: '',
            state: '',
            address: '',
            phone: '',
            confirmPassword: '',
            password: '',
        });
        setPasswordError(false);
    };


    useEffect( () => {
        let prevScrollPos = window.scrollY;

        const handleScroll = () => {
            const currentScrollPos = window.scrollY;
            setIsScrollingUp(currentScrollPos < prevScrollPos);
            prevScrollPos = currentScrollPos;
        };

        window.addEventListener("scroll", handleScroll);
        async function getProfile() {
            const wallet = await fcl.logIn();
        console.log({ wallet });
        console.log(wallet.addr);
        fetch(`http://16.170.224.207/profile/${wallet.addr}`)
         .then((response) => response.json())
         .then((data) => {
            console.log(data);
         })
         .catch((err) => {
            console.log(err.message);
         });
        }

        getProfile();

        return () => window.removeEventListener("scroll", handleScroll);
    }, []);

    return (
        <>
            <div className="flex items-start flex-col bg-white w-[100%] mt-[68px]  -ml-4">
                <header className="fixed inset-x-0 mb-12 top-0 sm-custom:z-50">
                    <nav
                        className={`flex  items-center justify-between p-6  ${isScrollingUp ? "bg-white" : "bg-white"
                            }`}
                        aria-label="Global"
                    >
                        <div className="flex lg:min-w-0 lg:flex-1">
                            <a href="/" className="-m-1.5 p-1.5">
                                <span className="sr-only">Flow grant</span>
                                <Image
                                    className="flex-shrink-0 lg:w-[180px] lg:h-[38px] md:w-[182px] w-[120px] h-[25px]"
                                    src={logo}
                                    alt="logo"
                                />
                            </a>
                        </div>
                    </nav>
                </header>
                <div className="w-[100%] lg:flex justify-between px-4 lg:bg-cover   items-center " style={{ backgroundImage: `url('/images/dashframe.png')` }} >
                    <div className="flex flex-col justify-center  h-[64px] " >
                        <p className=" lg:text-[24px] text-base text-white -mb-2">Welcome, Innovator ✨</p>
                    </div>
                </div>
                <div className="w-[100%]">
                    <div className="flex flex-col lg:mt-[12px] mt-[18px]  gap-y-[12px]">
                        <div className="lg:h-[980px] w-[100%] border-[2px]  lg:px-[30px] lg:py-[20px] justify-between  border-[#00EF8B] p-[8px] ">
                            <h1 className="text-[40px] text-center text-[#00EF8B] font-extrabold mb-4">Create profile</h1>
                            {submittedData ? (
                                <div className="flex items-center mt-6 justify-center">
                                    <p className="text-green-500">Form submitted successfully!</p>
                                    <button
                                        className="ml-2 text-green-500 focus:outline-none"
                                        onClick={() => setSubmittedData(null)}
                                    >
                                        <svg
                                            xmlns="http://www.w3.org/2000/svg"
                                            viewBox="0 0 24 24"
                                            fill="none"
                                            stroke="currentColor"
                                            strokeWidth="2"
                                            strokeLinecap="round"
                                            strokeLinejoin="round"
                                            className="w-4 h-4"
                                        >
                                            <line x1="18" y1="6" x2="6" y2="18" />
                                            <line x1="6" y1="6" x2="18" y2="18" />
                                        </svg>
                                    </button>
                                </div>
                            ) : (
                            <form onSubmit={handleSubmit}>
                                <div className="mb-4">
                                    {/* <label htmlFor="name" className="block mb-1 font-semibold">Name</label> */}
                                    <input
                                        type="text"
                                        id="FirstName"
                                        name="FirstName"
                                        placeholder='First name'
                                        onChange={handleChange}
                                        value={formData.FirstName}
                                        className="border-b-2 border-gray-300 px-4 py-2 outline-none rounded-md w-full"
                                        required
                                    />
                                </div>
                                <div className="mb-6">
                                    {/* <label htmlFor="name" className="block mb-1 font-semibold">Name</label> */}
                                    <input
                                        type="text"
                                        id="MiddleName"
                                        name="MiddleName"
                                        placeholder='Middle name'
                                        onChange={handleChange}
                                        value={formData.MiddleName}
                                        className="border-b-2 border-gray-300 px-4 py-2 outline-none rounded-md w-full"
                                    />
                                </div>
                                <div className="mb-6">
                                    {/* <label htmlFor="name" className="block mb-1 font-semibold">Name</label> */}
                                    <input
                                        type="text"
                                        id="LastName"
                                        name="LastName"
                                        placeholder='Last name'
                                        onChange={handleChange}
                                        value={formData.LastName}
                                        className="border-b-2 border-gray-300 px-4 py-2 outline-none rounded-md w-full"
                                        required
                                    />
                                </div>
                                <div className="mb-6">
                                    {/* <label htmlFor="message" className="block mb-1 font-semibold">Message</label> */}
                                    <input
                                        type="email"
                                        id="email"
                                        name="email"
                                        value={formData.email}
                                        onChange={handleChange}
                                        placeholder='Email'
                                        className="border-b-2 border-gray-300 px-4 py-2 outline-none rounded-md w-full"
                                        required
                                    />
                                </div>
                                <div className="mb-6">
                                    {/* <label htmlFor="message" className="block mb-1 font-semibold">Message</label> */}
                                    <input
                                        type="text"
                                        id="github"
                                        name="github"
                                        value={formData.github}
                                        onChange={handleChange}
                                        placeholder='Github Profile'
                                        className="border-b-2 border-gray-300 px-4 py-2 outline-none rounded-md w-full"
                                        required
                                    />
                                </div>
                                <div className="mb-6">
                                    {/* <label htmlFor="message" className="block mb-1 font-semibold">Message</label> */}
                                    <input
                                        type="text"
                                        id="country"
                                        name="country"
                                        value={formData.country}
                                        onChange={handleChange}
                                        placeholder='Country of residence'
                                        className="border-b-2 border-gray-300 px-4 py-2 outline-none rounded-md w-full"
                                        required

                                    />
                                </div>
                                <div className="mb-6">
                                    {/* <label htmlFor="message" className="block mb-1 font-semibold">Message</label> */}
                                    <input
                                        type="text"
                                        id="state"
                                        name="state"
                                        value={formData.state}
                                        onChange={handleChange}
                                        placeholder='State of residence'
                                        className="border-b-2 border-gray-300 px-4 py-2 outline-none rounded-md w-full"
                                        required

                                    />
                                </div>
                                <div className="mb-6">
                                    {/* <label htmlFor="message" className="block mb-1 font-semibold">Message</label> */}
                                    <input
                                        type="text"
                                        id="address"
                                        name="address"
                                        value={formData.address}
                                        onChange={handleChange}
                                        placeholder='Address'
                                        className="border-b-2 border-gray-300 px-4 py-2 outline-none rounded-md w-full"
                                        required
                                    />
                                </div>
                                <div className="mb-6">
                                    {/* <label htmlFor="message" className="block mb-1 font-semibold">Message</label> */}
                                    <input
                                        type="tel"
                                        id="phone"
                                        name="phone"
                                        value={formData.phone}
                                        onChange={handleChange}
                                        placeholder='Phone'
                                        className="border-b-2 border-gray-300 px-4 py-2 outline-none rounded-md w-full"
                                        required
                                    />
                                </div>
                                <div className="mb-6">
                                    {/* <label htmlFor="password" className="block mb-1 font-semibold">Password</label> */}
                                    <div className="relative">
                                        <input
                                            type={showPassword ? 'text' : 'password'}
                                            id="password"
                                            name="password"
                                            value={formData.password}
                                            onChange={handleChange}
                                            placeholder='Password'
                                            className="border-b-2 border-gray-300 px-4 py-2 outline-none rounded-md w-full pr-10"
                                            required
                                        />
                                        <div className="absolute right-0 top-0 mt-3 mr-3">
                                            {showPassword ? (
                                                <AiOutlineEyeInvisible
                                                    className="text-gray-500 cursor-pointer"
                                                    onClick={toggleShowPassword}
                                                />
                                            ) : (
                                                <AiOutlineEye
                                                    className="text-gray-500 cursor-pointer"
                                                    onClick={toggleShowPassword}
                                                />
                                            )}
                                        </div>
                                    </div>
                                </div>
                                <div className="mb-6">
                                    {/* <label htmlFor="confirmPassword" className="block mb-1 font-semibold">Confirm Password</label> */}
                                    <div className="relative">
                                        <input
                                            type={showConfirmPassword ? 'text' : 'password'}
                                            id="confirmPassword"
                                            name="confirmPassword"
                                            value={formData.confirmPassword}
                                            onChange={handleChange}
                                            placeholder='Confirm password'
                                            className={`border-b-2 ${passwordError ? 'border-red-500' : 'border-gray-300'} px-4 outline-none py-2 rounded-md w-full pr-10`}
                                            required
                                        />
                                        <div className="absolute right-0 top-0 mt-3 mr-3">
                                            {showConfirmPassword ? (
                                                <AiOutlineEyeInvisible
                                                    className="text-gray-500 cursor-pointer"
                                                    onClick={toggleShowConfirmPassword}
                                                />
                                            ) : (
                                                <AiOutlineEye
                                                    className="text-gray-500 cursor-pointer"
                                                    onClick={toggleShowConfirmPassword}
                                                />
                                            )}
                                        </div>
                                    </div>
                                    {passwordError && <p className="text-red-500 text-sm mt-1">Passwords do not match.</p>}
                                </div>



                                <div className='flex items-center mt-[75px] mb-[10px] justify-center'>
                                    <button
                                        type="submit"
                                        className="bg-[#00EF8B] hover:bg-[#07a261]  text-black text-[15px] lg:text-[25px]  font-semibold py-3 px-8 rounded-sm"
                                    >
                                        Submit
                                    </button>
                                </div>
                            </form>
                            )}
                        </div>
                    </div>
                </div>
            </div>
        </>
    )
}

export default Profile